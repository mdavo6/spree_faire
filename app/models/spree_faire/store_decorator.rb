module SpreeFaire
  module StoreDecorator
    def self.prepended(base)
      base.belongs_to :user
      base.has_many :faire_transactions
    end
  end
end

::Spree::Store.prepend(SpreeFaire::StoreDecorator) if ::Spree::Store.included_modules.exclude?(SpreeFaire::StoreDecorator)
