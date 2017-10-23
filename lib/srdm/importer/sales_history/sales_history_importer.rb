require 'csv'
require 'set'
require 'progress_bar'

module SRDM
  module Importer
    class SalesHistoryImporter
      MAX_RETRIES = 3

      attr_reader :import_file, :springboard, :ticket_lines, :ticket_count, :success_count

      def initialize(sales_history_file, client, options = {})
        @import_file = CSV.read(sales_history_file, headers: true)
        @springboard = client
        parse_options(options)
        parse_valid_import_times
        $custom_fields = FieldManager.new(@springboard)
        $account = AccountPrepper.new(
          @springboard,
          use_cache: @use_cache,
          refresh_cache: @refresh_cache,
          skip_tickets: @skip_ticket_download
        )
        @ticket_lines = Hash.new { |hash, key| hash[key] = [] }
        @ticket_count = 0
        @success_count = 0
      end

      def import
        process_import_file
        build_tickets
        check_for_duplicate_tickets
        wait_until_import_is_ready_to_start
        begin
          import_tickets
        ensure
          wrap_up_import
        end
      end

      private

      def import_tickets
        bar = ProgressBar.new tickets.count
        tickets.each do |ticket|
          when_ready_to_import do
            @ticket_count += 1
            import_ticket(ticket)
            bar.increment!
          end
        end
      end

      def wrap_up_import
        $custom_fields.reactivate
        LOG.info "Done! Successfully imported #{success_count} / #{ticket_count} tickets"
        LOG.info "Failed tickets exported to #{ticket_failure_output.path}" if @ticket_failure_output
      end

      def wait_until_import_is_ready_to_start
        if @import_start_time && !@valid_import_hours.include?(Time.now.hour)
          LOG.warn "Waiting until #{@import_start_time}:00 to begin the import"
        end
        when_ready_to_import { LOG.info 'Beginning ticket import' }
      end

      def when_ready_to_import(&blk)
        sleep(1) until @valid_import_hours.include? Time.now.hour
        $custom_fields.while_deactivated do
          yield
        end
      end

      def parse_options(options)
        @use_cache = options[:use_cache] || true
        @refresh_cache = options[:refresh_cache] || false
        @skip_ticket_download = options[:skip_ticket_download] || false
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

      def tickets
        @tickets ||= build_tickets
      end

      def check_for_duplicate_tickets
        used_ticket_nums = Set.new
        conflict_count = 0
        tickets.each do |ticket|
          conflict_count += 1 if used_ticket_nums.include?(ticket.ticket_number)
          used_ticket_nums << ticket.ticket_number
        end
        if conflict_count > 0
          raise "Found #{conflict_count} duplicate ticket numbers. Please resolve the issues on your file."
        end
      end

      def build_tickets
        LOG.info 'Building ticket requests'
        bar = ProgressBar.new ticket_lines.count
        @tickets = sorted_ticket_lines.each_with_object([]) do |(_key, lines), array|
          ticket = Ticket.new(lines)
          array << ticket if needs_import?(ticket)
          bar.increment!
        end
      end

      def sorted_ticket_lines
        @ticket_lines.sort_by { |_key, lines| lines.first['local_completed_at'] }.reverse
      end

      def needs_import?(ticket)
        !$account.tickets.include?(ticket.ticket_number)
      end

      def import_ticket(ticket)
        retry_count = 0
        begin
          @springboard[:sales][:tickets].post!(ticket.to_h)
          @success_count += 1
        rescue Springboard::Client::RequestFailed => err
          if err.response.body.details['qty'] && (retry_count += 1) <= MAX_RETRIES
            ticket.flatten_line_qtys
            retry
          end
          handle_failed_ticket_request(ticket, err)
        rescue => err
          retry if (retry_count += 1) <= MAX_RETRIES
          handle_unknown_ticket_failure(ticket, err)
        end
      end

      def handle_unknown_ticket_failure(ticket, err)
        LOG.error "Failed to import ticket #{ticket.ticket_number} #{err}"
        begin
          ticket_details = ticket.to_h
        rescue => err
          ticket_details = nil
        end
        ticket_failure_output << [ticket.ticket_number, err, ticket_details, nil, nil, nil]
      end

      def handle_failed_ticket_request(ticket, err)
        LOG.error "Failed to import ticket #{ticket.ticket_number} #{err}"
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
        subdomain = springboard.base_uri.hostname.split('.').first
        csv = CSV.open("./tmp/#{subdomain}_failed_tickets_#{Date.today}.csv", 'w')
        csv << ['Ticket #', 'Error', 'Request Body', 'Response Code', 'Response Body', 'Response Headers']
        csv
      end

      def process_import_file
        LOG.info 'Processing sales history import file'
        bar = ProgressBar.new @import_file.count
        import_file.each do |line|
          ticket_lines[ticket_key(line)] << line
          bar.increment!
        end
      end

      def ticket_key(line)
        "#{line['ticket_number']}-#{line['location_public_id']}-#{line['local_completed_at']}-#{line['customer_public_id']}"
      end
    end
  end
end
