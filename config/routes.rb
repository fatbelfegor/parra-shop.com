ParraShopCom::Application.routes.draw do
  get "admin/index"
  get "catalog/index"
  devise_for :users
  get "images/delete", to: 'images#delete'
  
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
  get '/kupit/:id', to: 'products#buy'
  get '/kupit/:scode', to: 'products#buy'
  get '/:scode', to: 'categories#catalog'
end