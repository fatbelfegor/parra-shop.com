class AddSortColumnsToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :color, :string
  	add_column :products, :texture, :string
  	add_column :products, :length, :integer
  	add_column :products, :width, :integer
  	add_column :products, :height, :integer
  end
end
