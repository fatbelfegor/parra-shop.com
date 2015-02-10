Rails.application.routes.draw do

  devise_for :users

  post 'create_admin', to: 'admin/admin#create_admin'
  match 'admin', to: 'admin/admin#home', via: [:get, :post]
  get 'admin/welcome', to: 'admin/welcome#welcome'

  match 'admin/model', to: 'admin/model#index', via: [:get, :post]
  match 'admin/model/new', to: 'admin/model#new', via: [:get, :post]
  match 'admin/model/habtm', to: 'admin/model#habtm', via: [:get, :post]
  post 'admin/model/create', to: 'admin/model#create'
  post 'admin/model/:model/update', to: 'admin/model#update'
  post 'admin/model/:model/destroy', to: 'admin/model#destroy'
  match 'admin/model/:model/edit', to: 'admin/model#edit', via: [:get, :post]
  get 'admin/model/:model', to: 'admin/model#show'

  match 'admin/model/:model/new', to: 'admin/record#new', via: [:get, :post]
  match 'admin/model/:model/edit/:id', to: 'admin/record#edit', via: [:get, :post]
  match 'admin/model/:model/records', to: 'admin/record#index', via: [:get, :post]
  post 'admin/model/:model/destroy/:id', to: 'admin/record#destroy'
  post 'admin/model/:model/update/:id', to: 'admin/record#update'
  post 'admin/model/:model/create', to: 'admin/record#create'
  post 'admin/model/:model/update', to: 'admin/record#update'
  post 'admin/record/get', to: 'admin/record#get'

  get 'admin/images', to: 'admin/image#index'
  get 'admin/images/upload', to: 'admin/image#upload'
  post 'admin/images/upload', to: 'admin/image#save'
  post 'admin/images/destroy', to: 'admin/image#destroy'

  match 'admin/components', to: 'admin/components#index', via: [:get, :post]
  post 'admin/components/create', to: 'admin/components#create'

  match 'admin/controllers', to: 'admin/controllers#index', via: [:get, :post]
  match 'admin/controllers/:contr', to: 'admin/controllers#show', via: [:get, :post]
  post 'admin/controllers/:contr/update', to: 'admin/controllers#update'
  post 'admin/controllers/:contr/action/create', to: 'admin/controllers#action_create'

  match 'admin/settings/localization', to: 'admin/settings#localization', via: [:get, :post]
  match 'admin/settings/template_form', to: 'admin/settings#template_form', via: [:get, :post]
  match 'admin/settings/template_index', to: 'admin/settings#template_index', via: [:get, :post]
  post 'admin/write', to: 'admin/admin#write'

  get 'admin/ordergen/:id/*anything', to: 'admin/orders#xlsx'

  match 'admin/packinglist', to: 'admin/packinglist#index', via: [:get, :post]
  post 'admin/packinglist/create', to: 'admin/packinglist#create'
  post 'admin/packinglist/update', to: 'admin/packinglist#update'
  match 'admin/packinglist/:id', to: 'admin/packinglist#show', via: [:get, :post]

end