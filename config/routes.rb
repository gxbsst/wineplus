Wineplus::Application.routes.draw do



  # Add your extension routes here
  match '/alipay_checkout/done' => 'spree/checkout#alipay_done', :as => :alipay_done
  match '/alipay_checkout/notify' => 'spree/checkout#alipay_notify', :as => :alipay_notify
  # get '/alipay_checkout/done/' => 'checkout#alipay_done', :as => :alipay_done
  #  post '/alipay_checkout/done/' => 'checkout#alipay_done', :as => :alipay_done 

  post 'checkout/update/:state', to: "spree/checkout#update"
  # match 'account/orders' => 'spree/users#orders', as: 'user_orders'
  get 'account/orders', :to => 'spree/users#orders', as: 'user_orders'

  # STATIC
  statics = %w(about_us contact_us faqs privacy)
  statics.each do |i|
    match "/#{i}", :to => "statics##{i}"
  end

  Spree::Core::Engine.routes.draw do
    devise_for :spree_user,
               :class_name => 'Spree::User',
               :controllers => { :sessions => 'spree/user_sessions',
                                 :registrations => 'spree/user_registrations',
                                 :passwords => 'spree/user_passwords' },
               :skip => [:unlocks, :omniauth_callbacks],
               :path_names => { :sign_out => 'logout' },
               :path_prefix => :user

    namespace :account do 
      resources :addresses
    end
    
  end

  Spree::Core::Engine.routes.prepend do
    resources :users, :only => [:edit, :update]

    devise_scope :spree_user do
      get '/login' => 'user_sessions#new', :as => :login
      post '/login' => 'user_sessions#create', :as => :create_new_session
      get '/logout' => 'user_sessions#destroy', :as => :logout
      get '/signup' => 'user_registrations#new', :as => :signup
      post '/signup' => 'user_registrations#create', :as => :registration
      get '/password/recover' => 'user_passwords#new', :as => :recover_password
      post '/password/recover' => 'user_passwords#create', :as => :reset_password
      get '/password/change' => 'user_passwords#edit', :as => :edit_password
      put '/password/change' => 'user_passwords#update', :as => :update_password
    end

    match '/checkout/registration' => 'checkout#registration', :via => :get, :as => :checkout_registration
    match '/checkout/registration' => 'checkout#update_registration', :via => :put, :as => :update_checkout_registration

    resource :session do
      member do
        get :nav_bar
      end
    end

    # resource :account, :controller => 'users'

    # namespace :admin do
    #   resources :users
    # end
  end
  
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'

  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :alipay_checkout_payment
        get :alipay_done
        post :alipay_notify
      end
    end
  end


  
          # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
