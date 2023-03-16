class FaireInventoryUpdateJob < ActiveJob::Base
  queue_as :default
  
  def perform(order_id, store_id)
    service = Faire::UpdateInventory.new(order_id: order_id, store_id: store_id)
    unless service.call
      raise Exception.new(service.errors.to_s)
    end
  end
end
