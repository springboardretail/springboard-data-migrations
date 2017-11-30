require 'bundler/setup'
require 'springboard-retail'
require 'logger'
require 'yaml'
require_relative 'srdm/importer'
require_relative 'srdm/field_manager'
require_relative 'srdm/resource_list'

module SRDM
  VERSION = '0.1.0'

  LOG = Logger.new(STDOUT)

  attr_reader :config

  def SRDM.load_config_file!(config_file)
    @config_file = YAML.load_file(config_file)
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
    client = Springboard::Client.new(base_uri,token: config.sr_token)
  end
end
