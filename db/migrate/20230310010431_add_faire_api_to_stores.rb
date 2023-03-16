class AddFaireApiToStores < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_stores, :faire_api_key, :string
  end
end
