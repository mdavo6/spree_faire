module Spree
  module Admin
	   module StoresControllerDecorator
       
       def self.prepended(base)
         base.before_action :load_all_users, only: %i[new edit]
       end
       
       def sync_inventory
         store = Spree::Store.find(params[:id])
         service = Faire::SyncInventory.new(store)
         if service.call
           flash[:success] = Spree.t(:inventory_sync_success)
         else
           raise Exception.new(service.errors.to_s)
           flash[:error] = Spree.t(:inventory_sync_error)
         end
         redirect_to admin_stores_path
       end
       
       def pull_orders
         store = Spree::Store.find(params[:id])
         service = Faire::OrderProcessing.new(store: store)
         if service.call
           flash[:success] = Spree.t(:orders_pulled_success)
         else
           raise Exception.new(service.errors.to_s)
           flash[:error] = Spree.t(:orders_pulled_error)
         end
         redirect_to admin_stores_path
       end
       
       
       private
        
        def load_all_users
          @users = Spree::User.all
        end
       
     end
  end
end

::Spree::Admin::StoresController.prepend(Spree::Admin::StoresControllerDecorator) if ::Spree::Admin::StoresController.included_modules.exclude?(Spree::Admin::StoresControllerDecorator)
