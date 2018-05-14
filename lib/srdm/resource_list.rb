require 'progress_bar'
require 'set'

module SRDM
  class ResourceList
    RESOURCE_GROUP_ID = {
      'items' => 'item',
      'customers' => 'customer',
      'sales/tickets' => 'sales.transaction'
    }

    attr_reader :resource_path, :resource_name, :springboard, :lookup_key, :value_key,
                :use_cache, :refresh_cache, :alt_lookups, :show_bar, :bar

    def initialize(resource_path, client, options = {})
      @resource_path = resource_path
      @resource_name = resource_path.split('/').last
      @springboard = client
      init_options(options)
      @bar = ProgressBar.new(resource.count) if show_bar
    end

    def to_h
      values
    end

    def to_set
      values.keys.to_set
    end

    def values
      @values ||= collect_values
    end

    def resource
      if @ticket_filter && @resource_name == 'tickets'
        springboard[resource_path].filter(@ticket_filter).sort(:id).query(per_page: 500)
      else
        springboard[resource_path].sort(:id).query(per_page: 500)
      end
    end

    def count
      resource.count
    end

    private

    def init_options(options)
      @lookup_key = options[:lookup_key] || 'public_id'
      @value_key = options[:value_key] || 'id'
      @use_cache = options[:use_cache] || false
      @alt_lookups = options[:alt_lookups] || true
      @show_bar = options[:show_bar] || true
      @refresh_cache = options[:refresh_cache] || false
      @ticket_filter = options[:ticket_filter]
    end

    def collect_values
      if use_cache && cache_exists? && !refresh_cache
        load_cache
      else
        download
      end
    end

    def load_cache
      File.open(cache_filepath) do |f|
        LOG.debug "Reading #{resource_name} from cache"
        Marshal.load(f)
      end
    end

    def cache_exists?
      File.exist?(cache_filepath)
    end

    def cache_filepath
      "./tmp/#{SRDM.subdomain}_#{resource_name}#{'_with_alts' if alt_lookups}_cache"
    end

    def save_cache(downloaded_resource)
      LOG.debug "Updating #{resource_name} cache"
      File.open(cache_filepath, 'w') { |f| Marshal.dump(downloaded_resource, f) }
    end

    def alt_lookup_fields
      @alt_lookup_fields ||= collect_alt_lookup_fields
    end

    def collect_alt_lookup_fields
      group_id = RESOURCE_GROUP_ID[resource_path]
      fields = @springboard[:custom_fields].filter(group_id: group_id, unique: true)
      fields.map { |field| field['key'] }
    end

    def id_filtered_resource(last_id, &blk)
      resource.filter(id: { '$gt' => last_id }).each { |thing| yield thing }
    end

    def download
      LOG.debug "Downloading #{resource_name}"
      last_id_downloaded = 0
      downloaded_records = {}
      begin
        id_filtered_resource(last_id_downloaded) do |thing|
          downloaded_records[thing[lookup_key]] = thing[value_key]
          if alt_lookups
            alt_lookup_fields.each do |field_key|
              downloaded_records[thing['custom'][field_key]] = thing[value_key] if thing['custom'][field_key]
            end
          end
          last_id_downloaded = thing.id
          bar.increment! if bar
        end
      rescue
        retry
      end
      save_cache(downloaded_records) if use_cache
      downloaded_records
    end
  end
end
