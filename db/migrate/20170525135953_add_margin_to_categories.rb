class AddMarginToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :margin, :integer
  end
end
