@db.init ['image', 'product', 'extension', 'category', 'subcategory', 'subcategory_item', 'size', 'color', 'texture', 'option', 'order', 'status', 'order_item', 'virtproduct', 'packinglist', 'packinglistitem', 'banner', 'user', 'user_log', 'page']
@admin_menu = "<li data-route='model/category'>
	<div class='icon fade'><a href='/admin/model/category/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/category/records' onclick='app.aclick(this)'><i class='icon-stack'></i><span>Категории</span></a>
</li>
<li data-route='model/product'>
	<div class='icon fade'><a href='/admin/model/product/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/product/records' onclick='app.aclick(this)'><i class='icon-stack'></i><span>Товары</span></a>
</li>
<li data-route='model/extension'>
	<a href='/admin/model/extension/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы товаров</span></a>
</li>
<li data-route='model/order'>
	<a href='/admin/model/order/records' onclick='app.aclick(this)'>
		<i class='icon-cart4'></i><span>Заказы</span>
	</a>
</li>
<li data-route='model/status'>
	<div class='icon fade'><a href='/admin/model/status/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/status/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы заказов</span></a>
</li>
<li data-route='model/packinglist'>
	<a href='/admin/model/packinglist/records' onclick='app.aclick(this)'><i class='icon-credit'></i><span>Список накладных</span></a>
</li>
<li data-route='model/banner'>
	<a href='/admin/model/banner/records' onclick='app.aclick(this)'><i class='icon-image'></i><span>Баннеры</span></a>
</li>
<li data-route='model/user'>
	<div class='icon fade'><a href='/admin/model/user/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/user/records' onclick='app.aclick(this)'><i class='icon-users'></i><span>Пользователи</span></a>
</li>
<li data-route='model/page'>
	<div class='icon fade'><a href='/admin/model/page/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/page/records' onclick='app.aclick(this)'><i class='icon-file6'></i><span>Страницы</span></a>
</li>"
@manager_menu = "<li data-route='model/order/records'>
	<a href='/admin/model/order/records' onclick='app.aclick(this)'>
		<i class='icon-cart4'></i><span>Заказы</span>
	</a>
</li>
<li data-route='model/status'>
	<div class='icon fade'><a href='/admin/model/status/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/status/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы заказов</span></a>
</li>
<li data-route='model/packinglist'>
	<div class='icon fade'><a href='/admin/model/packinglist/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/packinglist/records' onclick='app.aclick(this)'><i class='icon-credit'></i><span>Список накладных</span></a>
</li>
<li data-route='model/extension'>
	<div class='icon fade'><a href='/admin/model/extension/new' onclick='app.aclick(this)'><i class='icon-pen2'></i></a></div>
	<a href='/admin/model/extension/records' onclick='app.aclick(this)'><i class='icon-new'></i><span>Статусы товаров</span></a>
</li>"