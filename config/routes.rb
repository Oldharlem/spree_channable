Spree::Core::Engine.add_routes do

  namespace :admin do
    resources :channable_settings
  end

  namespace :api do
    namespace :v1 do
      resources :channable, only: [] do
        collection do
          get :product_feed
          get :variant_feed
        end
      end
    end
  end

end
