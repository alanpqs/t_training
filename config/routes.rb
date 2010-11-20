TTraining::Application.routes.draw do

  #get "countries/index"
  #get "users/index"
  #get "regions/index"
  #get "regions/new"
  #get "pages/home"
  #get "categories/index"
  #get "categories/new"
  #get "countries/index"
  #get "countries/new"
  #get "countries/create"
  #get "countries/edit"
  #get "countries/update"
  #get "countries/destroy"
  #get "currencies/index"
  #get "currencies/show"


  namespace "admin" do
    resources :regions, :countries, :categories
    resources :users,     :only => [:index, :show, :edit, :update, :destroy]
  end
  
  resources :users,       :except => :index
  resources :sessions,    :only => [:new, :create, :destroy]
  resources :countries
  resources :categories
  
  
  match '/signup',            :to => 'users#new'
  match '/login',             :to => 'sessions#new'
  match '/logout',            :to => 'sessions#destroy'
  match '/why_register',      :to => 'pages#why_register'
  match '/about',             :to => 'pages#about'
  match '/faqs',              :to => 'pages#faqs'
  match '/find_training',     :to => 'pages#find_training'
  match '/buyers',            :to => 'pages#buyers'
  match '/sellers',           :to => 'pages#sellers'
  match '/affiliates',        :to => 'pages#affiliates'
  match '/terms',             :to => 'pages#terms'
  match '/categories_admin',  :to => 'pages#categories_admin'
  match '/admin_home',        :to => 'admin/pages#home'

  root :to => 'pages#home'
  
  #get "pages/home"
  #get "pages/why_register"
  #get "pages/about"

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
