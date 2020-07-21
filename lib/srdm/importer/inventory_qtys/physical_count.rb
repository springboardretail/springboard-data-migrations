module SRDM
  module Importer
    class PhysicalCount
      attr_reader :heartland, :location_id, :reason_code, :status, :failed_lines

      def initialize(heartland, location_id, reason_code, resume_existing_count: false)
        @heartland = heartland
        @location_id = location_id
        @reason_code = reason_code
        @resume_existing_count = resume_existing_count
        @status = 'pending'
        @failed_lines = []
      end

      def add_line(item_num, qty)
        begin
          self.set_status('counting') if status != 'counting'
          batch[:lines].post!(item_lookup: item_num, qty: qty)
        rescue
          @failed_lines << [item_num, qty]
        end
      end

      def complete
        count_id = count.get.body.id
        if failed_lines.count > 0
          failed_lines.each { |line| LOG.warn "Failed to import line #{line}" }
          LOG.info "Leaving count #{count_id} pending so you can add missing lines to count"
        else
          self.set_status('finalizing')
          self.set_status('accepted')
          LOG.info "Physical count #{count_id} was successfully completed. Adjustments can take up to a few hours to complete"
        end
      end

      def set_status(new_status)
        count.put!(status: new_status)
        @status = new_status
      end

      private

      def batch
        @batch ||= create_batch
      end

      def create_batch
        begin
          count[:batches].post(description: 'Initial Import').resource
        rescue
          LOG.error "Failed to create batch for location ID #{location_id}"
        end
      end

      def count
        @count ||= find_or_create_count
      end

      def find_or_create_count
        begin
          if @resume_existing_count
            existing_count_filter = {'$and' => [{status: 'counting'}, {location_id: location_id}]}
            existing_count = heartland[:inventory][:physical_counts].filter(existing_count_filter).first
            return heartland[:inventory][:physical_counts][existing_count.id] if existing_count
          end
          create_count
        rescue
          LOG.error "Failed to find or create count for location ID #{location_id}"
        end
      end

      def create_count
        begin
          heartland[:inventory][:physical_counts].post(physical_count_request_body(location_id)).resource
        rescue
          LOG.error "Failed to create count for location ID #{location_id}"
        end
      end

      def physical_count_request_body(location_id)
        {
          adjustment_reason_id: reason_code,
          description: 'Initial Import',
          location_id: location_id,
          scope: 'full'
        }
      end
    end
  end
end
