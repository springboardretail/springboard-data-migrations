require_relative 'importer/csv_parser'
require_relative 'importer/error_helpers'
require_relative 'importer/sales_history/sales_history_importer'
require_relative 'importer/inventory_qtys/inventory_qty_importer'
require_relative 'importer/store_credits/store_credit_attacher'

module SRDM
  module Importer
    def Importer.sales_history(options)
      SalesHistoryImporter.new(options[:file], SRDM.client, options).import
    end

    def Importer.inventory_qtys(options)
      InventoryQtyImporter.new(options[:file], SRDM.client).import
    end

    def Importer.attach_store_credits(options)
      StoreCreditAttacher.new(options[:field_name], SRDM.client, options).attach
    end
  end
end
