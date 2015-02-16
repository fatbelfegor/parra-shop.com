models.order_index = {"table":[{"tr":[{"td":[{"field":"name","header":"Статус","belongs_to":"status"},{"cbParams":{"format":"dd.MM.yyyy"},"cbType":"date","field":"created_at","header":"Дата заказа","cb":"(function(d, params){return new Date(d).toString(params.format)})"},{"field":"phone","header":"Телефон"},{"header":"Сумма заказа","func":"( function (rec) {\n      price = 0;\n      items = record.where('order_item', {where: {'order_id': rec.id}}).records;\n      for (i = 0, len = items.length; i < len; i++) {\n        price += parseFloat(items[i].price) * items[i].quantity;\n      }\n      items = record.where('virtproduct', {where: {'order_id': rec.id}}).records;\n      for (i = 0, len = items.length; i < len; i++) {\n        price += parseFloat(items[i].price);\n      }\n      return price.toCurrency() + ' руб.';\n})"},{"header":"Сохранить в \"xlsx\"","btn":"custom","btnClick":"","btnTdClass":"blue","btnClass":"","btnIcon":"icon-print","btnA":"(function(rec){\n    if (me.prefix) {\n        prefix = ' ' + me.prefix\n    } else {\n        prefix = ''\n    }\n    number = rec.number || rec.id\n\treturn \"/admin/ordergen/\" + rec.id + \"/Заказ\" + prefix + \" \" + number + \".xlsx\"\n})"},{"btnClass":"edit","btnTdClass":"orange","btn":"edit","header":"Редактировать","btnA":"(function(rec, name){\n\treturn \"/admin/model/\" + name + \"/edit/\" + rec.id\n})"},{"btnClass":"remove","btnTdClass":"red","btn":"remove","header":"Удалить"}]}]}],"belongs_to":[{"model":"status"}],"has_many":[{"model":"order_item"},{"model":"virtproduct"}]}