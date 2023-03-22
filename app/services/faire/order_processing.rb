module Faire
  class OrderProcessing < ApplicationService

    def initialize(args = {})
      super
      @store = args[:store]
    end

    def call
      begin
        orders = get_orders(@store)
        process_orders(orders, @store)
      rescue ServiceError => error
        add_to_errors(error.messages)
      end

      completed_without_errors?
    end

    def get_orders(store)
      request = SpreeFaire::Api.new(store).get_processing_orders
      raise ServiceError.new([Spree.t(:error_requesting_processing)]) unless request.success?
      JSON.parse(request.body, symbolize_names: true)[:orders]
    end

    def process_orders(orders, store)
      orders.each do |order|
        # We only want to check inventory and import new orders
        unless Spree::FaireTransaction.find_by(faire_order_id: order[:display_id]).present?
          can_fulfill = true
          order[:items].each do |item|
            can_fulfill = check_stock(item[:sku], item[:quantity])
            raise ServiceError.new([Spree.t(:item_out_of_stock_error, item_name: item[:product_name])]) unless can_fulfill
            break unless can_fulfill
          end
          if can_fulfill
            order[:store] = store
            order_service = Faire::BuildOrder.new(order)
            raise ServiceError.new([Spree.t(:order_process_error, order_id: order[:order_id]), order_service.errors]) unless order_service.call
          end
        end
      end
    end

    def check_stock(sku, quantity)
      variant = Spree::Variant.find_by(sku: sku)

      variant.present? ? (quantity <= variant.quantity_check) : false
    end

  end
end
