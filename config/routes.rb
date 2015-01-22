ParraShopCom::Application.routes.draw do
  get '/otzyvy', to: 'main#otzyvy'
  get "/Jimmi", to: 'main#Jimmi'
  get "order_item/plus"
  get "order_item/minus"
  get "order_item/delete"
  get "catalog/index"
  get "catalog/(:url)", to: 'catalog#index'
  get "main/main"
  get 'users', to: 'users#index'
  get 'users/:id/logs', to: 'users#logs'
  devise_for :users
  get "images/delete", to: 'images#delete'
  get '/kupit/:scode', to: 'products#show_scode'
  get '/packinglist', to: 'packinglist#index'
  post '/packinglist', to: 'packinglist#index'
  get '/packinglist/:id', to: 'packinglist#show'
  patch '/packinglist', to: 'packinglist#update'
  delete '/packinglist/:id', to: 'packinglist#destroy'
  
  root to: 'main#index', as: 'index'

  get "stores", to: 'main#stores'
  get "store1", to: 'main#store1'
  get "mebelnyj-gipermarket-family-room", to: 'main#store2', as: 'store2'
  get "tk-armada", to: 'main#store3', as: 'store3'
  get "tc-cheremushki", to: 'main#store4', as: 'store4'
  get "tc roomer", to: 'main#store5', as: 'store5'
  get "tk-tvoj-dom-na-66-km-mkad", to: 'main#store6', as: 'store6'
  get "trc-rio-reutov", to: 'main#store7', as: 'store7'
  get "mc-vagant-podolsk", to: 'main#store8', as: 'store8'
  get "store9", to: 'main#store9'

  get "service", to: 'main#service'
  get "partners", to: 'main#partners'
  get "news", to: 'main#news'
  get "articles", to: 'main#articles'
  get "insurance", to: 'main#insurance'

  get 'orders/:id/Заказ :user_id :order_id.xlsx', to: 'orders#xlsx'

  post 'categories/copy', to: 'categories#copy'
  post 'catalog/products', to: 'catalog#products'
  post 'categories/sort', to: 'categories#sort'
  post 'products/sort', to: 'products#sort'
  post 'orders/discount_save', to: 'orders#discount_save'
  post 'orders/add_virtproduct', to: 'orders#addVirtproduct'
  post 'orders/edit_virtproduct_text', to: 'orders#editVirtproductText'
  post 'orders/edit_virtproduct_price', to: 'orders#editVirtproductPrice'
  post 'orders/destroy_virtproduct', to: 'orders#destroyVirtproduct'
  post 'orders/:id/status', to: 'orders#status'
  post 'users/role', to: 'users#role'
  post 'users/confirm', to: 'users#confirm'
  post 'users/:id/prefix', to: 'users#prefix'
  post 'users/admin-create', to: 'users#adminCreate'
  post 'users/destroy', to: 'users#destroy'
  
  resources :categories do
    member do
      resources :subcategories
    end
  end
  resources :images, :extensions
  resources :orders do
    resources :order_item, except: [:index, :show, :edit] do
      post :plus, on: :member
      post :minus, on: :member
    end
  end
  resources :statuses, except: [:show]
  resources :banners, except: [:show]
  resources :products, except: :index do
    member do
      get :show_scode
      resources :prsizes do
        member do
          resources :proptions
          resources :prcolors do
            get 'copy', to: 'prcolors#copy'
            member do
              resources :textures
            end
          end
        end
      end
    end
  end
  
  get '/cart.json', to: 'main#cartjson'
  get '/cart', to: 'main#cart'

  # Админка
  post 'create_admin', to: 'admin/admin#create_admin'
  match 'admin', to: 'admin/admin#home', via: [:get, :post]
  get 'admin/welcome', to: 'admin/welcome#welcome'

  match 'admin/model', to: 'admin/model#index', via: [:get, :post]
  match 'admin/model/new', to: 'admin/model#new', via: [:get, :post]
  match 'admin/model/habtm', to: 'admin/model#habtm', via: [:get, :post]
  post 'admin/model/create', to: 'admin/model#create'
  post 'admin/model/:model/update', to: 'admin/model#update'
  post 'admin/model/:model/destroy', to: 'admin/model#destroy'
  match 'admin/model/:model/edit', to: 'admin/model#edit', via: [:get, :post]
  get 'admin/model/:model', to: 'admin/model#show'

  match 'admin/model/:model/new', to: 'admin/record#new', via: [:get, :post]
  match 'admin/model/:model/edit/:id', to: 'admin/record#edit', via: [:get, :post]
  match 'admin/model/:model/records', to: 'admin/record#index', via: [:get, :post]
  post 'admin/model/:model/destroy/:id', to: 'admin/record#destroy'
  post 'admin/model/:model/update/:id', to: 'admin/record#update'
  post 'admin/model/:model/create', to: 'admin/record#create'
  post 'admin/model/:model/update', to: 'admin/record#update'
  post 'admin/record/get', to: 'admin/record#get'

  get 'admin/images', to: 'admin/image#index'
  get 'admin/images/upload', to: 'admin/image#upload'
  post 'admin/images/upload', to: 'admin/image#save'
  post 'admin/images/destroy', to: 'admin/image#destroy'

  match 'admin/components', to: 'admin/components#index', via: [:get, :post]
  post 'admin/components/create', to: 'admin/components#create'

  match 'admin/controllers', to: 'admin/controllers#index', via: [:get, :post]
  match 'admin/controllers/:contr', to: 'admin/controllers#show', via: [:get, :post]
  post 'admin/controllers/:contr/update', to: 'admin/controllers#update'
  post 'admin/controllers/:contr/action/create', to: 'admin/controllers#action_create'

  match 'admin/settings/localization', to: 'admin/settings#localization', via: [:get, :post]
  match 'admin/settings/template_form', to: 'admin/settings#template_form', via: [:get, :post]
  match 'admin/settings/template_index', to: 'admin/settings#template_index', via: [:get, :post]
  post 'admin/write', to: 'admin/admin#write'

  get 'admin/ordergen/:id/*anything', to: 'admin/orders#xlsx'

  match 'admin/packinglist', to: 'admin/packinglist#index', via: [:get, :post]
  post 'admin/packinglist/update', to: 'admin/packinglist#update'
  post 'admin/packinglist/upload', to: 'admin/packinglist#upload'
  match 'admin/packinglist/:id', to: 'admin/packinglist#show', via: [:get, :post]

  get '*anything', to: 'application#page404'
end