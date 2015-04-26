Rails.application.routes.draw do

  root to: 'page#index', as: 'index'

  get "catalog/index"
  get "catalog/(:url)", to: 'catalog#index'
  post "catalog/products"
  get 'kupit/:scode', to: 'catalog#product'
  get 'orders/:id/Заказ :user_id :order_id.xlsx', to: 'orders#xlsx'
  get 'cart.json', to: 'page#cartjson'
  get 'cart', to: 'page#cart'
  post 'orders', to: 'order#create', as: :orders

  # Что касается админки

  devise_for :users

  match 'admin', to: 'admin/admin#home', via: [:get, :post]
  get 'admin/welcome', to: 'admin/welcome#welcome'

  post 'admin/db/get', to: 'admin/db#get'
  post 'admin/db/save', to: 'admin/db#save'
  post 'admin/db/create_one', to: 'admin/db#create_one'
  post 'admin/db/update_one', to: 'admin/db#update_one'
  post 'admin/model/:model/destroy/:id', to: 'admin/db#destroy'

  match 'admin/model', to: 'admin/model#index', via: [:get, :post]
  match 'admin/model/new', to: 'admin/model#new', via: [:get, :post]
  match 'admin/model/habtm', to: 'admin/model#habtm', via: [:get, :post]
  post 'admin/model/create', to: 'admin/model#create'
  post 'admin/model/:model/update', to: 'admin/model#update'
  post 'admin/model/:model/destroy', to: 'admin/model#destroy'
  match 'admin/model/:model/edit', to: 'admin/model#edit', via: [:get, :post]
  match 'admin/model/:model/index', to: 'admin/model#index', via: [:get, :post]
  get 'admin/model/:model', to: 'admin/model#show'
  match 'admin/model/:model/templates/form', to: 'admin/model#template_form', via: [:get, :post]
  match 'admin/model/:model/templates/index', to: 'admin/model#template_index', via: [:get, :post]

  match 'admin/model/:model/new', to: 'admin/record#new', via: [:get, :post]
  match 'admin/model/:model/edit/:id', to: 'admin/record#edit', via: [:get, :post]
  match 'admin/model/:model/records', to: 'admin/record#index', via: [:get, :post]
  post 'admin/record/change', to: 'admin/record#change'
  post 'admin/record/copy', to: 'admin/record#copy'
  post 'admin/record/sort_with_parent', to: 'admin/record#sort_with_parent'
  post 'admin/record/sort_all', to: 'admin/record#sort_all'

  get 'admin/images', to: 'admin/image#index'
  get 'admin/images/upload', to: 'admin/image#upload'
  post 'admin/images/upload', to: 'admin/image#save'
  post 'admin/images/destroy', to: 'admin/image#destroy'

  match 'admin/components', to: 'admin/components#index', via: [:get, :post]
  post 'admin/components/create', to: 'admin/components#create'

  post 'admin/write', to: 'admin/admin#write'
  post 'admin/images_sort', to: 'admin/admin#images_sort'
  post 'admin/checkuniq', to: 'admin/admin#checkuniq'
  post 'admin/editorimage', to: 'admin/record#editorimage'

  get 'admin/ordergen/:id/*anything', to: 'admin/orders#xlsx'

  post 'admin/packinglist/create', to: 'admin/packinglist#create'
  post 'admin/packinglist/update', to: 'admin/packinglist#update'

  # Страницы

  get ':url', to: 'page#show'

end