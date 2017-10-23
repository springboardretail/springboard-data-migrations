require 'bundler/setup'
require 'springboard-retail'
require 'yaml'
# require './lib/resource_list'
# Dir["./lib/inventory_qtys/*.rb"].each {|file| require file }
# Dir["./lib/sales_history/*.rb"].each {|file| require file }
# Dir["./lib/store_credits/*.rb"].each {|file| require file }

class SRImporter
  def initialize(config_file)
    @config_file = config_file
  end

  def import_sales_history(import_file)
    # SalesHistoryImporter.new(import_file, client).import
    LOG.info "This is where I will start a sales history import"
  end

  def import_inventory_qtys(import_file)
    # InventoryQtyImporter.new(import_file, client).import
    LOG.info "This is where I will start an inventory qty import"
  end

  def attach_store_credits(field_name = 'Store Credit #')
    # StoreCreditAttacher.new(field_name, client).attach
    LOG.info "This is where I will start attaching store credits to gift cards"
  end

  private

  def config
    $config ||= load_config!
  end

  def load_config!
    YAML.load_file @config_file
  end

  def client
    @client ||= create_client
  end

  def create_client
    base_uri = "https://#{config['sr_subdomain']}.myspringboard.us/api"
    client = Springboard::Client.new(base_uri,token: config['sr_token'])
  end
end
