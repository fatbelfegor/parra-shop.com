@settings.template.index.model.order =
	string: [{name: 'name', type: 'string', belongs_to: 'status'},{name: 'created_at', type: 'datetime'},{name: 'phone', type: 'string'},{"custom":true,"title":"Сумма заказа","cb":"(function(){\n    var items = tables['order_item'].records;\n    var len = items.length;\n    var price = 0;\n    for(var i = 0; i < len; i++){\n        if(items[i].order_id == rec.id){\n            price += parseFloat(items[i].price);\n        }\n    }\n    return price + ' руб.'\n})()"}]
	text: []
	has_many: ['order_items']
	buttons: [(rec) -> "<a href='/admin/ordergen/#{rec.id}/Заказ #{me.prefix || ''} #{rec.number || rec.id}.xlsx' class='btn' style='color: #006eff'><i class='icon-print'></i></a>"]