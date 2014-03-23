ParraShopCom::Application.routes.draw do
  devise_for :users
  get "main/index"
  
  root to: 'main#index', as: 'main'

  resources :products
  resources :images
end
