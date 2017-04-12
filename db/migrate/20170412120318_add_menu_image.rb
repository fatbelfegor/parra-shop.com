class AddMenuImage < ActiveRecord::Migration
  def change
  	add_column :categories, :menu_image, :string
  end
end
