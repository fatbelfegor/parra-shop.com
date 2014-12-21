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
  resources :images
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
  get '*anything', to: 'application#page404'
end