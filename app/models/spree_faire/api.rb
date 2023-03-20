class SpreeFaire::Api
  attr_reader :response, :store

  def initialize(store)
    @store = store
    @response = nil
  end
  
  def get_processing_orders
    excluded_states = "NEW,PRE_TRANSIT,IN_TRANSIT,DELIVERED,PENDING_RETAILER_CONFIRMATION,BACKORDERED,CANCELED"
    # Can include ship_after_max to only pull orders which are eligible for shipping (ie. exclude orders with a future shipment date)
    # ship_after_max = Time.now.utc.iso8601
    @response = SpreeFaire::Request.new(@store).get("/orders?excluded_states=" + excluded_states) # + "&ship_after_max=" + ship_after_max)
  end
  
  def products
    limit = "250"
    @response = SpreeFaire::Request.new(@store).get("/products?limit=" + limit)
  end
  
  def update_inventory_levels_by_sku(inventory_data)
    @response = SpreeFaire::Request.new(@store).patch("/products/variants/inventory-levels-by-skus", inventory_data)
  end

end
