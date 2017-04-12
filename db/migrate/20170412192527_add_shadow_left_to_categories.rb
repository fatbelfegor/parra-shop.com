class AddShadowLeftToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :shadow_left, :boolean, default: true
  end
end
