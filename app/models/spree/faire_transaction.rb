module Spree
  class FaireTransaction < ActiveRecord::Base
    belongs_to :order
    belongs_to :store

    def reusable_sources(_order)
      []
    end

    def self.with_payment_profile
      []
    end

    def name
      'Faire'
    end
  end
end
