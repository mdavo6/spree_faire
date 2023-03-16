class FaireOrdersJob < ActiveJob::Base
  queue_as :default
  
  def perform
    store = Spree::Store.find_by(code: "faire")
    service = Faire::OrderProcessing.new(store: store)
    unless service.call
      raise Exception.new(service.errors.to_s)
    end
  end
end
