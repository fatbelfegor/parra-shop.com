class SeoToColorCategories < ActiveRecord::Migration
  def change
  	add_column :color_categories, :title, :string
  	add_column :color_categories, :keywords, :string
  	add_column :color_categories, :description, :string
  end
end
