module SRDM
  module Importer
    module ErrorHelpers
      def unfixable_request_error?(err)
        if err_has_response_body?(err)
          return true if ['payment_error', 'validation_error'].include?(err.response.body.error)
        end
        false
      end

      def ticket_qty_error?(err)
        return false unless err_has_response_body?(err)
        return true if err.response.body.respond_to?(:details) && err.response.body.details['qty']
        false
      end

      def error_message(err)
        if err_has_response_body?(err)
          return "#{err.response.body.message} #{err.response.body.details.to_json}"
        end
        err
      end

      def err_has_response_body?(err)
        err.respond_to?(:response) && err.response.respond_to?(:body)
      end
    end
  end
end