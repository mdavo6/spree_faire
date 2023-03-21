module SpreeFaire
  module OrderDecorator
    def self.prepended(base)
      base.has_one :faire_transaction, dependent: :destroy
      base.state_machine.after_transition to: :complete, do: :update_faire, unless: :faire_order?
    end

    def update_faire
      # Need API key from Faire store
      faire_store = Spree::Store.find_by(code: "faire")
      FaireInventoryUpdateJob.perform_later self.id, faire_store.id
    end
    
    def faire_order?
      store.code.include?("faire")
    end
  end
end

::Spree::Order.prepend(SpreeFaire::OrderDecorator) if ::Spree::Order.included_modules.exclude?(SpreeFaire::OrderDecorator)
