require_relative 'item_line'
require_relative 'payment'
require_relative 'shipping_line'
require_relative 'tax_line'
require 'time'

module SRDM
  module Importer
    class Ticket
      attr_reader :lines, :station, :customer_number, :completed_at, :sales_rep,
                  :location_public_id, :tax, :item_lines, :tax_lines, :shipping_lines,
                  :local_completed_at

      attr_accessor :ticket_number

      def initialize(lines)
        @lines = lines             
        process_ticket_details
        process_lines
      end

      def to_h
        {
          public_id: ticket_number,
          station_id: station_id,
          customer_public_id: customer_public_id,
          created_at: completed_at,
          completed_at: completed_at,
          sales_rep: sales_rep,
          item_lines: Array(item_lines).map(&:to_h),
          tax_lines: Array(tax_lines).map(&:to_h),
          payments: [ticket_payment.to_h],
          affect_inventory: false,
          recalculate: false,
          status: 'complete',
          'custom@adm_imported_at' => Time.now.iso8601
        }
      end

      def location
        @location ||= $account.locations_and_stations[lines.first['location_public_id']]
      end

      def station_id
        begin
          location.stations.first.id
        rescue
          raise RuntimeError, "Station missing for location #{location_public_id}"
        end
      end

      def customer_public_id
        return @customer_number if $account.customers.include? @customer_number
        $account.default_customer.public_id
      end

      def flatten_line_qtys
        @item_lines = lines.each_with_object([]) do |line, array|
          line['qty'].to_i.times do
            line['qty'] = 1
            array << ItemLine.new(line)
          end
        end
      end

      private

      def ticket_lines
        @item_lines + @tax_lines.to_a + @shipping_lines.to_a
      end

      def process_ticket_details
        @ticket_number = lines.first['ticket_number']
        @customer_number = lines.first['customer_public_id']
        @sales_rep = lines.first['sales_rep']
        @location_public_id = lines.first['location_public_id']
        @local_completed_at = lines.first['local_completed_at']
        @completed_at = parse_completed_at(lines.first)
      end

      def parse_completed_at(line)
        begin
          Time.parse(line['local_completed_at']).utc.iso8601
        rescue
          raise "Failed to parse timestamp \"#{line['local_completed_at']}\" expected iso8601 format timestamp"
        end
      end

      def ticket_payment
        @ticket_payment ||= Payment.new(self, ticket_lines)
      end

      def process_lines
        @item_lines = lines.map { |line| ItemLine.new(line) }
        @tax_lines = [TaxLine.new(lines.first)] if lines.first['tax'].to_f != 0
        @shipping_lines = [ShippingLine.new(lines.first)] if lines.first['shipping'].to_f != 0    
      end
    end
  end
end
