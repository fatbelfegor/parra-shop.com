class CreateColorCategories < ActiveRecord::Migration
	def change
		# create_table :color_categories do |t|
		# 	t.belongs_to :category, index: true
		# 	t.string :image
		# 	t.string :url, index: true
		# 	t.string :name
		# 	t.timestamps null: false
		# end
		# add_column :products, :color_category_id, :integer, index: true
		# add_index :categories_products, :category_id
		# add_index :categories_products, :product_id
		# add_index :categories, :parent_id
		# add_index :products, :category_id
		# add_index :products, :extension_id
	end
end
