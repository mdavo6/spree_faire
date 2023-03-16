class AddUserToStores < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_stores, :user, references: :spree_users, index: true
  end
end
