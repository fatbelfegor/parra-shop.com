ParraShopCom::Application.routes.draw do
  get "admin/index"
  get "catalog/index"
  devise_for :users
  get "main/index"
  get "images/delete", to: 'images#delete'
  
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
  
  resources :products do
    get :show_scode, on: :member
  end
  
  get '/cart', to: 'main#cart'
  get '/kupit/:scode', to: 'products#buy'
  get '/:scode', to: 'categories#catalog'
end
