module SRDM
  class FieldManager
    def initialize(client, *groups, include_settings: true)
      @springboard = client
      @include_settings = include_settings
      @groups = groups
      @groups = ['sales.transaction', 'sales.transaction.line_item'] if groups.count.zero?
      @required_custom_fields = []
      @required_settings = []
      find_required_fields
      log_required_fields
    end

    def status
      @current_status ||= 'Active'
    end

    def deactivate
      return 'Deactivated' if status == 'Deactivated'
      @required_settings.each { |setting| change_setting_required_status(setting, false) } if @include_settings
      @required_custom_fields.each { |field_id| change_custom_field_required_status(field_id, false) }
      LOG.info "Required #{@groups} fields deactivated"
      @current_status = 'Deactivated'
    end

    def reactivate
      return 'Active' if status == 'Active'
      @required_settings.each { |setting| change_setting_required_status(setting, true) } if @include_settings
      @required_custom_fields.each { |field_id| change_custom_field_required_status(field_id, true) }
      LOG.info "Required #{@groups} fields reactivated"
      @current_status = 'Active'
    end

    def required_count
      count = @required_custom_fields.count
      count += @required_settings.count if @include_settings
    end

    def log_required_fields
      if @include_settings
        @required_settings.each { |setting| LOG.info "Account has #{setting.split('.').last.gsub('_', ' ')} for POS" }
      end
      LOG.info "Account has #{@required_custom_fields.count} required custom #{@groups} fields"
    end

    def while_deactivated(&blk)
      if @required_custom_fields.count.zero? && @required_settings.count.zero?
        yield
      else
        begin
          previous_status = status
          deactivate
          yield
        ensure
          reactivate if previous_status == 'Active'
        end
      end
    end

    private

    def change_setting_required_status(setting, value)
      @springboard[:settings][setting].put!(value: value)
    end

    def change_custom_field_required_status(field_id, value)
      @springboard[:custom_fields][field_id].put!(required: value)
    end

    def required?(setting)
      @springboard[:settings][setting].get.body.value
    end

    def find_required_fields
      find_required_settings if @include_settings
      find_required_custom_fields
    end

    def find_required_settings
      @required_settings << 'pos.tickets.customer_required' if required?('pos.tickets.customer_required')
      @required_settings << 'pos.tickets.sales_rep_required' if required?('pos.tickets.sales_rep_required')
      if required?('pos.tickets.reason_of_adjusting_price_required')
        @required_settings << 'pos.tickets.reason_of_adjusting_price_required'
      end
    end

    def find_required_custom_fields
      group_ids = @groups.map { |group| {group_id: group} }
      custom_field_groups = {'$or' => group_ids }
      @springboard[:custom_fields].filter(custom_field_groups).filter(required: true).each do |field|
        @required_custom_fields << field.id
      end
    end
  end
end
