module SRDM
  module Importer
    class ItemLine
      attr_reader :line, :unit_price, :qty

      def initialize(line)
        @line = line
        process_line_details
      end

      def to_h
        line_details = {
          type: 'ItemLine',
          item_lookup: item_lookup,
          unit_price: unit_price.to_f,
          qty: qty.to_i
        }
        line_details.merge!({ original_unit_price: original_price.to_f }) if original_price
        line_details.merge!({ description: description }) if description
        line_details
      end

      def total
        @total ||= unit_price * qty
      end

      def description
        @description ||= line['description']
      end

      def item_lookup
        return line['item_lookup'] if $account.items.include? line['item_lookup']
        @description = line['description'] || line['item_lookup']
        $account.default_item.public_id
      end

      def original_price
        oprice = line['original_price'] || line['original_unit_price']
        return nil if oprice.nil?
        BigDecimal.new(oprice)
      end

      private

      def process_line_details
        @unit_price = BigDecimal.new(line['unit_price'])
        @qty = line['qty'].to_f
      end
    end
  end
end