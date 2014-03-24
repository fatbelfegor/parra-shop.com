class CategoriesProductsJoin < ActiveRecord::Migration
  def change
  	create_table :categories_products, :id => false do |t|
	  t.references :category, :null => false
	  t.references :product, :null => false
	end
  end
end
