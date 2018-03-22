require_relative 'physical_count'
require 'csv'
require 'progress_bar'

module SRDM
  module Importer
    class InventoryQtyImporter
      attr_reader :import_file, :springboard, :options, :reason_name, :inventory_counts

      def initialize(inventory_qty_file, client, options)
        @import_file = CSVParser.new(inventory_qty_file)
        @springboard = client
        @options = options
        @reason_name = options[:reason_code] || 'Initial Import'
        @inventory_counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      end

      def import
        process_import_file
        inventory_counts.each do |location, items|
          count = physical_count(location)
          if count
            LOG.info "Adding items to physical count for location #{location}"
            add_items_to_count(count, items)
            count.complete
          end
        end
      end

      private

      def add_items_to_count(count, items)
        bar = ProgressBar.new items.count
        items.each do |item_num, qty|
          count.add_line(item_num, qty)
          bar.increment!
        end
      end

      def physical_count(location)
        begin
          location_filter = {'$or' => [{name: location}, {public_id: location}]}
          location_id = @springboard[:locations].filter(location_filter).first.id
          PhysicalCount.new(
            springboard,
            location_id,
            reason_code,
            resume_existing_count: @options[:resume_physical_counts]
          )
        rescue
          LOG.error "Failed to create physical count for location \"#{location}\", skipping this location"
          return nil
        end
      end

      def process_import_file
        import_file.each do |line|
          location = line['Location'] || line['Location #']
          item = line['Item #'] || line['Item']
          qty = line['Qty'] || line['Quantity']
          inventory_counts[location][item] += qty.to_i
        end
      end

      def reason_code
        @reason_code ||= find_or_create_reason_code
      end

      def find_or_create_reason_code
        begin
          existing_code = @springboard[:reason_codes][:inventory_adjustment_reasons].filter(name: reason_name).first
          return existing_code.id if existing_code
          LOG.warn "Creating new inventory adjustment reason code #{reason_name}"
          @springboard[:reason_codes][:inventory_adjustment_reasons].post(
            name: reason_name,
            description: reason_name
          ).resource.get.body.id
        rescue
          LOG.error "Unable to find or create #{reason_name} reason code"
        end
      end
    end
  end
end
