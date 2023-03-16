class CreateSpreeFaireTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_faire_transactions do |t|
      t.string :faire_order_id
      t.references :store, index: true
      t.references :order, index: true
      t.timestamps
    end
  end
end
