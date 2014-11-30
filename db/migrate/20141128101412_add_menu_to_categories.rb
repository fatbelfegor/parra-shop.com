class AddMenuToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :menu, :bool
  end
end
