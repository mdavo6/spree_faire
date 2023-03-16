class AddFaireOrderIdToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_orders, :faire_order_id, :string
  end
end
