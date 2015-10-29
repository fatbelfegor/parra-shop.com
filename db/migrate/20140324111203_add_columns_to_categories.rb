class AddColumnsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :commission, :decimal, precision: 18, scale: 2, default: 0
  	add_column :categories, :rate, :decimal, precision: 18, scale: 2, default: 0
  end
end
