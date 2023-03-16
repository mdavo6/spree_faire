class Spree::Core::Importer::Faire::Order < Spree::Core::Importer::Order
  class << self
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
