require 'bigdecimal'

module SRDM
  module Importer
    class TaxLine
      attr_reader :line, :amount

      def initialize(line)
        @line = line
        process_line_details
      end

      def to_h
        {
          type: 'TaxLine',
          description: 'Sales Tax',
          value: amount.to_f
        }
      end

      def total
        @amount
      end

      private

      def process_line_details
        @amount = BigDecimal.new(line['tax'])
      end
    end
  end
end
