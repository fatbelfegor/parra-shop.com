ParraShopCom::Application.routes.draw do
  get "/Jimmi", to: 'main#Jimmi'
  get "order_item/plus"
  get "order_item/minus"
  get "order_item/delete"
  get "catalog/index"
  get "main/main"
  devise_for :users
  get "images/delete", to: 'images#delete'
  get '/kupit/:scode', to: 'products#show_scode'
  get '/prcolors/copy', to: 'prcolors#copy'
  get '/configurator', to: 'configurator#index'
  
  root to: 'main#index', as: 'index'

  get "stores", to: 'main#stores'
  get "store1", to: 'main#store1'
  get "store2", to: 'main#store2'
  get "store3", to: 'main#store3'
  get "store4", to: 'main#store4'
  get "store5", to: 'main#store5'
  get "store6", to: 'main#store6'
  get "store7", to: 'main#store7'
  get "store8", to: 'main#store8'

  get "service", to: 'main#service'
  get "partners", to: 'main#partners'
  get "news", to: 'main#news'
  get "articles", to: 'main#articles'
  get "insurance", to: 'main#insurance'

  get 'orders/:id/заказ.xlsx', to: 'orders#xlsx'

  post 'categories/sort', to: 'categories#sort'
  post 'products/sort', to: 'products#sort'
  post 'orders/discount_save', to: 'orders#discount_save'
  
  resources :categories, :images, :prsizes, :textures, :proptions, :prcolors
  resources :orders do
    get :exec, on: :member
    get :deny, on: :member
    resources :order_item, except: [:index, :show, :edit] do
      post :plus, on: :member
      post :minus, on: :member
    end
  end
  
  resources :products, except: :index do
    get :show_scode, on: :member
  end
  
  get '/cart.json', to: 'main#cartjson'
  get '/cart', to: 'main#cart'
  get '*anything', to: 'application#page404'
end