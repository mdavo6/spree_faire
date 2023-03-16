module Faire
  class UpdateInventory < ApplicationService
    
    attr_reader :update_json, :store

    def initialize(args = {})
      super
      @order = Spree::Order.find(args[:order_id])
      @store = Spree::Store.find(args[:store_id])
      @update_inventory_hash = []
    end

    def call
      begin
        update_inventory(@order)
      rescue ServiceError => error
        add_to_errors(error.messages)
      end

      completed_without_errors?
    end
  
    def update_inventory(order)
      order.line_items.each do |line_item|
        variant = line_item.variant
        @update_inventory_hash << update_inventory_json(variant)
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
