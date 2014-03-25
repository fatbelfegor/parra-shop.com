ParraShopCom::Application.routes.draw do
  devise_for :users
  get "main/index"
  
  root to: 'main#main', as: 'main'

  #resources :categories, :collection => { :sort => :post}
  resources :categories do
      collection do
         post 'sort'
      end
  end
  resources :products
  resources :images
  resources :prsizes
  resources :prcolors
  resources :proptions

  get '/cart', to: 'main#cart'
  get '/kupit/:scode', to: 'products#buy'
  get '/:scode', to: 'categories#catalog'
end
