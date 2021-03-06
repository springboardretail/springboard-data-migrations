require 'set'

module SRDM
  module Importer
    class AccountPrepper
      DEFAULT_ITEM_REQUEST_BODY = {
        public_id: 'MISC',
        cost: 0,
        description: 'Miscellaneous item',
        prompt_for_price: true
      }

      DEFAULT_CUSTOMER_REQUEST_BODY = {
        public_id: 'CASH',
        first_name: 'Walk-in',
        last_name: 'Customer'
      }

      def initialize(client, use_cache: true, refresh_cache: false, ticket_cache: false, skip_tickets: false)
        @heartland = client
        @use_cache = use_cache
        @refresh_cache = refresh_cache
        @ticket_cache = ticket_cache
        @skip_tickets = skip_tickets
        download_initial_resources
      end

      def customers
        @customers ||= SRDM::ResourceList.new(
          'customers',
          @heartland,
          use_cache: @use_cache,
          refresh_cache: @refresh_cache
        ).to_h
      end

      def items
        @items ||= SRDM::ResourceList.new(
          'items',
          @heartland,
          use_cache: @use_cache,
          refresh_cache: @refresh_cache
        ).to_h
      end

      def tickets
        @tickets ||= _ticket_set
      end

      def _ticket_set
        return Set.new if @skip_tickets
        SRDM::ResourceList.new(
          'sales/tickets',
          @heartland,
          use_cache: @ticket_cache,
          refresh_cache: @refresh_cache,
          custom_filter: @custom_filter
        ).to_set
      end

      def custom_filter=(filter)
        @custom_filter = filter
      end

      def payment_type_id
        @payment_type_id ||= find_or_create_payment_type
      end

      def locations_and_stations
        @locations_and_stations ||= find_locations_and_stations
      end

      def refresh_locations_and_stations
        @locations_and_stations = nil
      end

      def create_defaults
        default_customer
        default_item
      end

      def default_customer
        @default_customer ||= find_or_create_default_customer
      end

      def default_item
        @default_item ||= find_or_create_default_item
      end

      private

      def download_initial_resources
        items
        customers
      end

      def find_or_create_default_item
        begin
          item = @heartland[:items].filter(public_id: 'MISC').first
          return item if item
          SRDM::LOG.info 'Creating default "MISC" item'
          custom_fields = FieldManager.new(@heartland, 'item', include_settings: false)
          custom_fields.while_deactivated do
            response = @heartland[:items].post(DEFAULT_ITEM_REQUEST_BODY)
            raise response.raw_body unless response.success?
            return response.resource.get.body
          end
        rescue => err
          abort("Failed to create default \"MISC\" item. Err: #{err} \nCancelling import!")
        end
      end

      def find_or_create_default_customer
        begin
          customer = @heartland[:customers].filter(public_id: 'CASH').first
          return customer if customer
          SRDM::LOG.info 'Creating default "CASH" customer'
          custom_fields = FieldManager.new(@heartland, 'customer', include_settings: false)
          custom_fields.while_deactivated do
            response = @heartland[:customers].post(DEFAULT_CUSTOMER_REQUEST_BODY)
            raise response.raw_body unless response.success?
            return response.resource.get.body
          end
        rescue
          abort("Failed to create default \"CASH\" customer. Err: #{err} \nCancelling import!")
        end
      end

      def find_locations_and_stations
        @heartland[:locations].embed(:stations).each_with_object({}) do |location, hash|
          hash[location['public_id']] = location
          hash[location['name']] = location
        end
      end

      def find_or_create_payment_type
        existing_payment_type = @heartland[:payment_types].filter(name: 'External').first
        return existing_payment_type.id if existing_payment_type
        SRDM::LOG.info "Creating custom payment type for imported tickets"
        begin
          @heartland[:payment_types].post!(name: 'External').resource.get.body.id
        rescue
          SRDM::LOG.error 'Failed to create custom payment type'
        end
      end
    end
  end
end
