ParraShopCom::Application.routes.draw do
  get "catalog/index"
  get "main/main"
  devise_for :users
  get "images/delete", to: 'images#delete'
  get '/kupit/:scode', to: 'products#show_scode'
  get '/prcolors/copy', to: 'prcolors#copy'
  
  root to: 'main#index', as: 'index'

  get "stores", to: 'main#stores'
  get "store1", to: 'main#store1'
  get "store2", to: 'main#store2'
  get "store3", to: 'main#store3'
  get "store4", to: 'main#store4'
  get "store5", to: 'main#store5'
  get "store6", to: 'main#store6'
  get "store7", to: 'main#store7'

  get "service", to: 'main#service'
  get "partners", to: 'main#partners'
  get "news", to: 'main#news'
  get "articles", to: 'main#articles'
  get "insurance", to: 'main#insurance'

  post 'categories/sort', to: 'categories#sort'
  post 'products/sort', to: 'products#sort'
  
  resources :categories
  resources :images
  resources :prsizes
  resources :prcolors
  resources :textures
  resources :proptions

  get 'products/index', to: 'main#page404'
  
  resources :products do
    get :show_scode, on: :member
  end
  
  get '/order', to: 'order#new'
  post '/order', to: 'order#create', as: "orders"
  get '/cart.json', to: 'main#cartjson'
  get '/cart', to: 'main#cart'
  get '*anything', to: 'application#page404'
end