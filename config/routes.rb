ParraShopCom::Application.routes.draw do
  devise_for :users
  get "main/index"
  
  root to: 'main#index', as: 'main'

  resources :categories
  resources :products
  resources :images

  get '/cart', to: 'main#cart'
  get '/kupit/:scode', to: 'products#buy'
  get '/:scode', to: 'categories#catalog'
end
