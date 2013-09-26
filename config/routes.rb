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
      resources :wish_lists do 
        resources :wish_list_items
      end
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

  end
  
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


  
end
