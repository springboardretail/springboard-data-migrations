require 'time'

module SRDM
  module Importer
    class Payment
      attr_reader :ticket, :lines, :total_payment

      def initialize(ticket, lines)
        @ticket = ticket
        @lines = lines
        @total_payment = BigDecimal.new(0)
        process_lines
      end

      def to_h
        {
          type: 'Payments::ExternalPayment',
          description: 'External',
          deposit: false,
          payment_type_id: $account.payment_type_id,
          amount: total_payment.to_f,
          completed_at: ticket.completed_at,
          updated_at: ticket.completed_at
        }
      end

      private

      def process_lines
        lines.each { |line| @total_payment += line.total }
      end
    end
  end
end