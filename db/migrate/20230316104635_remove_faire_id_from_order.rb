class RemoveFaireIdFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_orders, :faire_order_id
  end
end
