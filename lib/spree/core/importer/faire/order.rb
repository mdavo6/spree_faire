class Spree::Core::Importer::Faire::Order < Spree::Core::Importer::Order
  class << self

    # Override default import as need to use store_id to create order
    def import(user, params)
      ensure_country_id_from_params params[:ship_address_attributes]
      ensure_state_id_from_params params[:ship_address_attributes]
      ensure_country_id_from_params params[:bill_address_attributes]
      ensure_state_id_from_params params[:bill_address_attributes]

      # Add store_id to create_params
      create_params = params.slice(:currency, :store_id)
      order = Spree::Order.create! create_params
      order.associate_user!(user)

      shipments_attrs = params.delete(:shipments_attributes)

      create_line_items_from_params(params.delete(:line_items_attributes), order)
      create_shipments_from_params(shipments_attrs, order)
      create_adjustments_from_params(params.delete(:adjustments_attributes), order)
      create_payments_from_params(params.delete(:payments_attributes), order)

      if completed_at = params.delete(:completed_at)
        order.completed_at = completed_at
        order.state = 'complete'
      end

      params.delete(:user_id) unless user.try(:has_spree_role?, 'admin') && params.key?(:user_id)
      order.update!(params)
      order.create_proposed_shipments unless shipments_attrs.present?

      # Really ensure that the order totals & states are correct
      order.updater.update
      if shipments_attrs.present?
        order.shipments.each_with_index do |shipment, index|
          shipment.update_columns(cost: shipments_attrs[index][:cost].to_f) if shipments_attrs[index][:cost].present?
        end
      end
      order.reload
    rescue StandardError => e
      order.destroy if order&.persisted?
      raise e.message
    end
    
    # Override default create_payments because order requires response_code for Mirakl Orders
    def create_payments_from_params(payments_hash, order)
      return [] unless payments_hash
      payments_hash.each do |p|
        begin
          payment = order.payments.build order: order
          payment.amount = p[:amount].to_f
          payment.state = p[:state] || p[:status] || 'completed'
          payment.created_at = p[:created_at] if p[:created_at]
          payment.payment_method = Spree::PaymentMethod.find_by_name!(p[:payment_method])
          payment.source = create_source_payment_from_params(p[:source], payment) if p[:source]
          payment.response_code = p[:response_code]
          payment.save!
        rescue Exception => e
          raise "Order import payments: #{e.message} #{p}"
        end
      end
    end

    def create_source_payment_from_params(source_hash, payment)
      begin
        Spree::FaireTransaction.create!(
          order: payment.order,
          faire_order_id: source_hash[:faire_order_number],
          store_id: source_hash[:store_id]
         )
      rescue Exception => e
        raise "Order import source payments: #{e.message} #{source_hash}"
      end
    end
  end
end
