Dir["./lib/srdm/importer/inventory_qtys/*.rb"].each {|file| require file }
Dir["./lib/srdm/importer/sales_history/*.rb"].each {|file| require file }
Dir["./lib/srdm/importer/store_credits/*.rb"].each {|file| require file }

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
