app.menu_settings =
	admin: [
		'home',
		{model: 'category', name: 'Категории'},
		{model: 'product', name: 'Товары'},
		{model: 'extension', name: 'Статусы товаров', icon: 'icon-new'},
		'orders',
		{model: 'status', name: 'Статусы заказов', icon: 'icon-new'},
		'packinglists',
		{model: 'banner', name: 'Баннеры', icon: 'icon-image'},
		{model: 'user', name: 'Пользователи', icon: 'icon-users'},
		'sign_out'
	]
	manager: [
		'home',
		'orders',
		{model: 'status', name: 'Статусы заказов', icon: 'icon-new'},
		'packinglists',
		{model: 'extension', name: 'Статусы товаров', icon: 'icon-new'},
		'sign_out'
	]