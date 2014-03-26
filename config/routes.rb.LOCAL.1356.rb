ParraShopCom::Application.routes.draw do
  get "admin/index"
  get "catalog/index"
  get "catalog/cart"
  devise_for :users
  get "main/index"
  get "main/main"
  
  root to: 'main#index', as: 'index'
  
  get "main/stores", as: 'stores'
  get "main/store1", as: 'store1'
  get "main/store2", as: 'store2'
  get "main/store3", as: 'store3'
  get "main/store4", as: 'store4'
  get "main/store5", as: 'store5'
  get "main/store6", as: 'store6'
  get "main/store7", as: 'store7'
  
  get "main/service", as: 'service'
  get "main/partners", as: 'partners'
  get "main/news", as: 'news'
  get "main/articles", as: 'articles'
  get "main/insurance", as: 'insurance'
  

  resources :categories
  resources :products
  resources :images
  resources :prsizes
  resources :prcolors
  resources :proptions
  
  resources :products do
    get :show_scode, on: :member
  end

  get '/cart', to: 'main#cart'
  get '/kupit/:scode', to: 'products#buy'
  get '/:scode', to: 'categories#catalog'
end