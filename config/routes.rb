Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :stores do
      member do
        put :sync_inventory
      end
    end
  end
end
