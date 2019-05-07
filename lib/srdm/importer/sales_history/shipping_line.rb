require 'bigdecimal'

module SRDM
  module Importer
    class ShippingLine
      attr_reader :line, :amount

      def initialize(args)
        @line = line
        process_line_details
      end

      def to_h
        {
          type: 'ShippingLine',
          description: 'Shipping',
          value: amount.to_f
        }
      end

      def total
        @amount
      end

      private

      def process_line_details
        @amount = BigDecimal(line['shipping'])
      end
    end
  end
end
