# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].each do |i|
	name = "Product-#{i}"
	cat = Category.find_by_name('Bella')
	cat.products.create name: name, scode: name.downcase, category_id: cat.id, price: 10000
end