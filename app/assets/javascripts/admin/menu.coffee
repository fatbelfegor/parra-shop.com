app.menu_settings =
	admin: [
		'home',
		{model: 'category', name: 'Категории'},
		{model: 'product', name: 'Товары'},
		'orders',
		'packinglists',
		{model: 'banner', name: 'Баннеры', icon: 'icon-image'},
		{model: 'extension', name: 'Статусы товаров', icon: 'icon-new'},
		{model: 'user', name: 'Пользователи', icon: 'icon-users'},
		'sign_out'
	]
	manager: [
		'home',
		'orders',
		'packinglists',
		{model: 'extension', name: 'Статусы товаров', icon: 'icon-new'},
		'sign_out'
	]