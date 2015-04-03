Admin::RoleList = {
	admin: {
		all: true
	},
	manager: {
		log: {
			create: [
				{model: "extension", action: lambda {|r| "Создал статус товара \"#{r.name}\""}}
			],
			update: [
				{model: "extension", action: lambda {|r| "Обновил статус товара \"#{r.name}\""}}
			],
			destroy: [
				{model: "extension", action: lambda {|r| "Удалил статус товара \"#{r.name}\""}}
			]
		},
		record: [
				{model: "extension"},
				{model: "order"}
			],
		"admin/admin#home" => true,
		"admin/record#get" => true,
		"admin/record#new" => true,
		"admin/record#index" => true,
		"admin/record#edit" => true,
		"admin/record#save" => true,
		"admin/record#destroy" => true
	}
}