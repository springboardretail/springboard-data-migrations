module SRDM
  module Importer
    class StoreCreditAttacher
      attr_reader :field_name, :heartland, :attach_count, :gift_cards

      def initialize(field_name, client, options = {})
        @field_name = field_name
        @heartland = client
        @system = options[:system].to_s.strip.downcase
        @import_set_id = options[:import_set_id]
        @attach_count = 0
        download_gift_cards
        download_customers if @system.include?('counter') && @system.include?('point')
      end

      def attach
        LOG.info "Attaching gift cards to customers in the #{field_name} field"
        attach_gift_cards
        LOG.info "Finished attaching #{attach_count} gift cards to customers as store credits"
      end

      def custom_field
        @custom_field ||= find_or_create_custom_field
      end

      private

      def attach_gift_cards
        update_bar = ProgressBar.new gift_cards.count
        gift_cards.each_slice(100).each do |chunk|
          card_list = processed_list(chunk)
          matching_customers = customers_with_card_number(card_list)
          card_list.each do |gift_card|
            customer_id = matching_customers[gift_card]
            save_matching_gift_card(customer_id, gift_card) if customer_id
            update_bar.increment!
          end
        end
      end

      def save_matching_gift_card(customer_id, gift_card)
        heartland[:customers][customer_id].put! "custom@#{custom_field}" => gift_card_number(gift_card)
        @attach_count += 1
      end

      def gift_card_number(gift_card)
        return gift_card.gsub(/\W/, '') if @system.include?('light') && @system.include?('speed')
        return "C-#{gift_card}" if @system.include?('file') && @system.include?('maker')
        return "C#{gift_card}" if @system.include?('celerant')
        gift_card
      end

      def download_gift_cards
        options = { alt_lookups: false, lookup_key: 'number' }
        options[:custom_filter] = { import_set_id: @import_set_id } if @import_set_id
        @gift_cards = ResourceList.new('gift_cards', heartland, options).to_set
      end

      def download_customers
        @customers = ResourceList.new('customers', heartland, alt_lookups: false).to_h
      end

      def customers_with_card_number(card_list)
        if @customers
          card_list.each_with_object({}) { |e, hash| hash[e] = processed_customer_list[e] if processed_customer_list[e] }
        else
          cust_resource(card_list).each_with_object({}) { |cust, hash| hash[cust['public_id']] = cust['id']}
        end
      end

      def processed_customer_list
        @processed_customer_list ||= _processed_customer_list
      end

      def _processed_customer_list
        return counterpoint_processed_customer_list if @system.include?('counter') && @system.include?('point')
        @customers
      end

      def processed_list(chunk)
        return lightspeed_processed_chunk(chunk) if @system.include?('light') && @system.include?('speed')
        return filemaker_processed_chunk(chunk) if @system.include?('file') && @system.include?('maker')
        return celerant_processed_chunk(chunk) if @system.include?('celerant')
        chunk
      end

      def lightspeed_processed_chunk(chunk)
        chunk.map { |e| "#{e[0]}-#{e[1..-1]}" }
      end

      def filemaker_processed_chunk(chunk)
        chunk.map { |e| e[2..-1] }
      end

      def celerant_processed_chunk(chunk)
        chunk.reject { |e| e[0] != 'C' }.map { |e| e[1..-1] }
      end

      def counterpoint_processed_customer_list
        @customers.each_with_object({}) do |(public_id, id), hash|
          processed_public_id = public_id.delete('-').delete(' ').delete('.').delete('_').delete("'")
          hash[processed_public_id] = id
        end
      end

      def cust_resource(chunk)
        heartland[:customers].filter(public_id: {'$in' => chunk}).query('_only' => ['id', 'public_id'])
      end

      def find_or_create_custom_field
        begin
          custom_field_filter = {'$and' => [{'$or' => [{name: field_name}, {key: field_name}]},{group_id: 'customer'}]}
          existing_custom_field = @heartland[:custom_fields].filter(custom_field_filter).first
          return existing_custom_field['key'] if existing_custom_field
          heartland[:custom_fields].post!(
            group_id: 'customer',
            name: field_name,
            validation_type: 'text',
            metadata: {show_on_customer_list: 'true'}
          ).resource.get.body['key']
        rescue
          abort "Unable to find or create custom field #{field_name}"
        end
      end
    end
  end
end
