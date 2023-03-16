module SpreeFaire
  module VariantDecorator
    def quantity_check
      # If item is no longer available remove all stock
      if available?
        total_on_hand > 0 ? total_on_hand : 0
      else
        0
      end
    end
  end
end

::Spree::Variant.prepend(SpreeFaire::VariantDecorator) if ::Spree::Variant.included_modules.exclude?(SpreeFaire::VariantDecorator)
