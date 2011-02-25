TTraining::Application.routes.draw do

  get "recommendations/index"

  get "searchlists/index"

  get "searchlists/new"

  namespace "admin" do
    resources :regions, :countries, :categories, :category_approvals, :media, :fees
    resources :users,     :only => [:index, :show, :edit, :update, :destroy]
    resources :authorize_media
  end
  
  namespace "business" do
    resources :vendors
    resources :pages,       { :duplicate_to_vendors => :post }
    resources :media,       :only => [:new, :create]
    resources :categories,  :only => [:new, :create]
    resources :offers,      :only => :index
    #resources :issues
  end
  
  namespace "guest" do
    resources :resources,   :only => [:index, :show]  
  end
  
  namespace "member" do
    resources :resources,       :only => [:index, :show]
    resources :searchlists,     :except => :show
    resources :recommendations, :only => :index  
  end
  #namespace "events" do
  #  resources :items
  #end
  
  resources :users,         :except => :index
  resources :sessions,      :only => [:new, :create, :destroy]
  resources :categories
  resources :offers, :issues
  
  resources :vendors do
    resources :resources,   :shallow => true
  end
  
  resources :searchlists do
    resources :recommendations,   :only => :index
  end
  
  resources :resources do
    resources :items,             :shallow => true
    resources :unscheduled_items, :shallow => true
    resources :past_events,       :only => :index
  end
  
  resources :items do
    resources :issues,            :shallow => true
  end
  
  match '/confirm/:code',       :to => 'vendors#confirm', :constraints => { :code => /[A-Za-z0-9]{18}/ }
  match '/signup',              :to => 'users#new'
  match '/login',               :to => 'sessions#new'
  match '/logout',              :to => 'sessions#destroy'
  match '/why_register',        :to => 'pages#why_register'
  match '/about',               :to => 'pages#about'
  match '/faqs',                :to => 'pages#faqs'
  match '/find_training',       :to => 'pages#find_training'
  match '/buyers',              :to => 'pages#buyers'
  match '/sellers',             :to => 'pages#sellers'
  match '/affiliates',          :to => 'pages#affiliates'
  match '/terms',               :to => 'pages#terms'
  match '/categories_admin',    :to => 'pages#categories_admin'
  match '/admin_home',          :to => 'admin/pages#home'
  match '/business_home',       :to => 'business/pages#home'
  match '/forgotten_password',  :to => 'users#forgotten_password'
  match '/new_password',        :to => 'users#new_password'
  match '/resource_group',      :to => 'business/pages#resource_group'
  match '/duplicate_resource_to_vendor',  
                            :to => 'business/pages#duplicate_resource_to_vendor'
  match 'duplicate_to_vendor',  :to => 'business/pages#duplicate_to_vendor'
  match 'keyword_help',         :to => 'business/pages#keyword_help'
  match 'popular_keywords',     :to => 'business/pages#popular_keywords'
  match 'select_category',      :to => 'business/pages#select_category'
  match 'category_selected',    :to => 'business/pages#category_selected'
  match 'resource_activation',  :to => 'business/pages#resource_activation'
  match 'tickets_menu',         :to => 'business/pages#tickets_menu'
  match 'program_selection',    :to => 'business/pages#program_selection'
  match 'resource_selection',    :to => 'business/pages#resource_selection'
  match 't4t_intro',            :to => 'business/pages#t4t_intro'
  match 'vendor_account',       :to => 'business/pages#vendor_account'
  match 'member_home',          :to => 'member/pages#home'
  match 'member_focus',         :to => 'member/pages#focus'
  
  root :to => 'pages#home'

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
