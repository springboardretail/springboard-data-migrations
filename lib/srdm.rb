require 'bundler/setup'
require 'heartland-retail'
require 'logger'
require 'yaml'
require_relative 'srdm/importer'
require_relative 'srdm/field_manager'
require_relative 'srdm/resource_list'

module SRDM
  VERSION = '1.0.1'

  LOG = Logger.new(STDOUT)

  attr_reader :config

  def SRDM.load_config_file!(config_file)
    @config_file = YAML.load_file(config_file)
    LOG.info "Loaded config file for subdomain \"#{self.subdomain}\""
  end

  def SRDM.subdomain
    @subdomain ||= SRDM.config.sr_subdomain
  end

  def SRDM.subdomain=(subdomain)
    @subdomain = subdomain
  end

  def SRDM.client
    @client ||= create_client
  end

  def SRDM.config
    @config ||= OpenStruct.new(@config_file)
  end

  private

  def SRDM.create_client
    base_uri = "https://#{config.sr_subdomain}.myspringboard.us/api"
    client = HeartlandRetail::Client.new(base_uri,token: config.sr_token)
  end
end
