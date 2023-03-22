module Faire
  class BuildOrder < ApplicationService
    attr_reader :order

    def initialize(order = {})
      super
      @order_data = order
      @store = order[:store]
      @force_sync = order[:force_sync] || false
      @order_total = 0
      @order = nil
    end

    def call
      begin
        # If order already exist we dont want to remake it. We may want to alert admin some how with an email
        build_order_for_user(@order_data, @store)
      rescue ServiceError => error
        add_to_errors(error.messages)
      end

      completed_without_errors?
    end

    def get_order_hash(order_data, store)
      # Source has to come after order is created
      {
        email: store.user.email,
        channel: 'faire',
        store_id: store.id,
        line_items_attributes: line_items_hash(order_data[:items]),
        completed_at: order_data[:created_at],
        payments_attributes: [
          {
            amount: @order_total.to_f,
            payment_method: 'Faire',
            created_at: Time.current,
            response_code: order_data[:display_id],
            source: { faire_order_number: order_data[:display_id], store_id: store.id }
          }
        ],
        bill_address_attributes: build_address(order_data[:address], store.user),
        ship_address_attributes: build_address(order_data[:address], store.user)
      }
    end

    def line_items_hash(items)
      line_items = []
      items.each do |item|
        sku = item[:sku]
        quantity = item[:quantity]
        price = item[:price][:amount_minor]/100.0.to_d

        variant = Spree::Variant.includes(:stock_items).active.find_by(sku: sku)
        raise ServiceError.new(["Issue finding #{sku}"]) unless variant.present?

        @order_total += (price * quantity)
        line_items << { sku: variant.sku, quantity: quantity, price: price }
      end
      line_items
    end

    def build_order_for_user(order_data, store)
      @order = Spree::Core::Importer::Faire::Order.import(store.user, get_order_hash(order_data, store))
      update_shipping_method(order_data, store, @order)
      @order.shipments.each(&:finalize!) # This is required to decrease inventory
    end

    def update_shipping_method(order_data, store, order)
      order.shipments.each do |shipment|
        # will always be used on the back end
        shipment.refresh_rates(Spree::ShippingMethod::DISPLAY_ON_BACK_END)
        selected_rate = shipment.shipping_rates.detect { |rate|
          rate.shipping_method_id
        }
        shipment.selected_shipping_rate_id = selected_rate.id if selected_rate
      end
      # Update order to recalc totals so we can bring the paid balance to full with the newly selected shipping rate
      order.updater.update
      payment = order.payments.first
      payment.update(amount: payment.amount + order.shipments.sum(:cost))
    end

    def available_spree_shipping_methods(order_data, store)
      store.mirakl_shipping_options.find_by(shipping_type_label: order_data[:shipping_type_label])&.shipping_methods
    end

    def build_address(address, user)
      SpreeFaire::Address.new(address, user).build_address
    end

  end
end
