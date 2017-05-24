class AddMenuNameToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :menu_name, :string
    Category.find_each do |c|
    	c.update menu_name: c.name
    end
  end
end
