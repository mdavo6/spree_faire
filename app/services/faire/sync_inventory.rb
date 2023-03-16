module Faire
  class SyncInventory < ApplicationService
    
    attr_reader :update_json, :store

    def initialize(store = {})
      super
      @store = store
      @faire_variants = []
      @update_inventory_hash = []
    end

    def call
      begin
        products_data = get_faire_products()
        process_products_data(products_data)
        update_inventory()
      rescue ServiceError => error
        add_to_errors(error.messages)
      end

      completed_without_errors?
    end
    
    def process_products_data(products_data)
      products_data.each do |product|
        product[:variants].each do |variant|
          @faire_variants << variant[:sku]
        end
      end
    end
    
    def get_faire_products
      response = SpreeFaire::Api.new(@store).products
      raise ServiceError.new([Spree.t(:get_products_issue, response: response)]) unless response.success?
      JSON.parse(response.body, symbolize_names: true)[:products]
    end
  
    def update_inventory()
      spree_variants = Spree::Variant.active.where(show_in_product_feed: true)
      spree_variants.each do |variant|
        # Only update SKU's which already exist in Faire
        if @faire_variants.include? variant.sku
          @update_inventory_hash << update_inventory_json(variant)
        end
      end
      if @update_inventory_hash.present?
        update_inventory_json = "{\"inventories\":" + @update_inventory_hash.to_json + "}"
        response = SpreeFaire::Api.new(@store).update_inventory_levels_by_sku(update_inventory_json)
        raise ServiceError.new([Spree.t(:inventory_update_issue, response: response)]) unless response.success?
      end
    end
    
    def update_inventory_json(variant)
      {
        sku: variant.sku,
        current_quantity: variant.total_on_hand
      }
    end

  end
end
