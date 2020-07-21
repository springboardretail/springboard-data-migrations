require_relative 'account_prepper'
require_relative 'duplicate_ticket_checker'
require_relative 'ticket'
require 'csv'
require 'progress_bar'

module SRDM
  module Importer
    class SalesHistoryImporter
      include ErrorHelpers

      MAX_RETRIES = 5
      DEFAULT_OPTIONS = {
        skip_ticket_download: false,
        refresh_cache: false,
        use_cache: true
      }
      REQUIRED_FILE_HEADERS = ['ticket_number', 'local_completed_at', 'location_public_id', 'item_lookup', 'unit_price', 'qty', 'tax']
      EXTRA_FILE_HEADERS = ['customer_public_id', 'sales_rep', 'tax', 'original_price']
      LEGACY_HEADER_MAPPING = {
        'Ticket #' => 'ticket_number',
        'Customer #' => 'customer_public_id',
        'Completed At' => 'local_completed_at',
        'Sales Rep' => 'sales_rep',
        'Location #' => 'location_public_id',
        'Tax Total' => 'tax',
        'Item #' => 'item_lookup',
        'Item Original Unit Price' => 'original_price',
        'Item Adjusted Unit Price' => 'unit_price',
        'Item Qty' => 'qty'
      }

      attr_reader :import_file, :heartland, :ticket_lines, :ticket_count, :success_count

      def initialize(sales_history_file, client, options = {})
        @import_file = CSVParser.new(sales_history_file, header_mapping: LEGACY_HEADER_MAPPING)
        check_import_file_headers
        @heartland = client
        parse_options(options)
        parse_valid_import_times
        $custom_fields = FieldManager.new(@heartland)
        $account = AccountPrepper.new(
          @heartland,
          use_cache: @use_cache,
          refresh_cache: @refresh_cache,
          skip_tickets: @skip_ticket_download
        )
        @ticket_lines = Hash.new { |hash, key| hash[key] = [] }
        @ticket_count = 0
        @success_count = 0
      end

      def import
        begin
          process_import_file
          check_for_stations_and_locations
          download_existing_tickets
          build_tickets
          check_for_duplicate_tickets
          $account.create_defaults
          wait_until_import_is_ready_to_start
          begin
            import_tickets
          ensure
            wrap_up_import
          end
        rescue => err
          SRDM::LOG.error "Unknown error occurred: #{err}"
          STDERR.puts err.backtrace
        end
      end

      def tickets
        @tickets ||= build_tickets
      end

      private

      def import_tickets
        bar = ProgressBar.new tickets.count
        when_ready_to_import do
          SRDM::LOG.info 'Beginning ticket import'
          tickets.each do |ticket|
            @ticket_count += 1
            import_ticket(ticket)
            bar.increment!
          end
        end
      end

      def wrap_up_import
        $custom_fields.reactivate
        SRDM::LOG.info "Successfully imported #{success_count} out of #{tickets.count} tickets"
        SRDM::LOG.info "Failed tickets exported to #{ticket_failure_output.path}" if @ticket_failure_output
      end

      def wait_until_import_is_ready_to_start
        if @import_start_time && !@valid_import_hours.include?(Time.now.hour)
          SRDM::LOG.warn "Waiting until #{@import_start_time}:00 to begin the import"
        end
      end

      def when_ready_to_import(&blk)
        sleep(1) until @valid_import_hours.include? Time.now.hour
        $custom_fields.while_deactivated do
          yield
        end
      end

      def parse_options(options)
        options = DEFAULT_OPTIONS.merge(options)
        @use_cache = options[:use_cache]
        @refresh_cache = options[:refresh_cache]
        @skip_ticket_download = options[:skip_ticket_download]
        @skip_prompts = options[:skip_prompts]
        @chronological_order = options[:chronological_order]
        @import_start_time = options[:import_start_time].to_i if options[:import_start_time]
        @import_end_time = options[:import_end_time].to_i if options[:import_end_time]
      end

      def parse_valid_import_times
        if @import_start_time.nil? || @import_end_time.nil?
          @valid_import_hours = (0..24).to_a
        elsif @import_start_time < @import_end_time
          @valid_import_hours = (@import_start_time..@import_end_time).to_a
        else
          hours1 = (@import_start_time..24)
          hours2 = (0..@import_end_time)
          @valid_import_hours = hours1.to_a + hours2.to_a
        end
      end

      def check_import_file_headers
        headers = import_file.headers
        missing_headers = REQUIRED_FILE_HEADERS.each_with_object([]) do |header, arry|
          arry << header unless headers.include?(header)
        end
        unknown_headers = headers - REQUIRED_FILE_HEADERS - EXTRA_FILE_HEADERS
        if unknown_headers.count > 0
          SRDM::LOG.warn "The import file contains unknown headers that will be ignored #{unknown_headers}"
        end
        if missing_headers.count > 0
          SRDM::LOG.error "Missing required headers #{missing_headers}"
          exit
        end
      end

      def check_for_duplicate_tickets
        DuplicateTicketChecker.new(tickets).check!
      end

      def check_for_stations_and_locations
        location_ids = Set.new
        locations_missing_stations = Set.new
        missing_locations = Set.new
        raise('Import file does not contain any values for location_public_id') unless @location_public_ids.count > 0
        @location_public_ids.each do |location_public_id|
          location = $account.locations_and_stations[location_public_id]
          if location.nil?
            missing_locations << location_public_id
          else
            location_ids << location['id']
            locations_missing_stations << location_public_id unless location && location['stations'].count > 0
          end
        end
        raise("Missing Locations #{missing_locations.to_a}") if missing_locations.count > 0
        $account.custom_filter = { source_location_id: { '$in' => location_ids.to_a }}
        if locations_missing_stations.count > 0
          SRDM::LOG.warn "Missing stations in the following locations #{locations_missing_stations.to_a}"
          puts 'Would you like me to create the stations? (y/n)'
          if @skip_prompts || STDIN.gets.chomp.to_s.strip.downcase == 'y'
            create_stations(locations_missing_stations)
            $account.refresh_locations_and_stations
          else
            abort('Aborted by the user')
          end
        end
      end

      def create_stations(locations_missing_stations)
        locations_missing_stations.each do |location|
          sr_location = heartland[:locations].filter('$or' => [{public_id: location}, {name: location}]).first
          heartland[:stations].post!(location_id: sr_location.id, active: true, name: 'Station 1')
        end
        SRDM::LOG.info "Successfully created #{locations_missing_stations.count} stations"
      end

      def build_tickets
        SRDM::LOG.info 'Building ticket requests'
        bar = ProgressBar.new ticket_lines.count
        @tickets = sorted_ticket_lines.each_with_object([]) do |(_key, lines), array|
          ticket = Ticket.new(lines)
          array << ticket if needs_import?(ticket)
          bar.increment!
        end
      end

      def sorted_ticket_lines
        sorted_lines = @ticket_lines.sort_by { |_key, lines| lines.first['local_completed_at'] }
        return sorted_lines if @chronological_order
        sorted_lines.reverse
      end

      def needs_import?(ticket)
        !$account.tickets.include?(ticket.ticket_number)
      end

      def import_ticket(ticket)
        retry_count = 0
        begin
          @heartland[:sales][:tickets].post!(ticket.to_h)
          @success_count += 1
        rescue HeartlandRetail::Client::RequestFailed => err
          if (retry_count += 1) <= MAX_RETRIES
            ticket.flatten_line_qtys if ticket_qty_error?(err)
            retry unless unfixable_request_error?(err)
          end
          handle_failed_ticket_request(ticket, err)
        rescue => err
          retry if (retry_count += 1) <= MAX_RETRIES
          handle_unknown_ticket_failure(ticket, err)
        end
      end

      def handle_unknown_ticket_failure(ticket, err)
        SRDM::LOG.error "Failed to import ticket #{ticket.ticket_number} #{err}"
        begin
          ticket_details = ticket.to_h
        rescue => err
          ticket_details = nil
        end
        ticket_failure_output << [ticket.ticket_number, err, ticket_details, nil, nil, nil]
      end

      def handle_failed_ticket_request(ticket, err)
        SRDM::LOG.error "Failed to import ticket #{ticket.ticket_number} #{error_message(err)}"
        ticket_failure_output << [
          ticket.ticket_number,
          err,
          ticket.to_h,
          err.response.status,
          err.response.raw_body,
          err.response.headers
        ]
      end

      def ticket_failure_output
        @ticket_failure_output ||= create_ticket_failure_output
      end

      def create_ticket_failure_output
        csv = CSV.open("./tmp/#{SRDM.subdomain}_failed_tickets_#{Date.today}.csv", 'w')
        csv << ['Ticket #', 'Error', 'Request Body', 'Response Code', 'Response Body', 'Response Headers']
        csv
      end

      def process_import_file
        SRDM::LOG.info 'Processing sales history import file'
        bar = ProgressBar.new @import_file.count
        @location_public_ids = Set.new
        import_file.each do |line|
          ticket_lines[ticket_key(line)] << line
          @location_public_ids << line['location_public_id']
          bar.increment!
        end
      end

      def ticket_key(line)
        [
          line['ticket_number'],
          line['location_public_id'],
          line['local_completed_at'],
          line['customer_public_id']
        ].join('-')
      end

      def download_existing_tickets
        $account.tickets
      end
    end
  end
end
