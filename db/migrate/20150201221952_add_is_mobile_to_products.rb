class AddIsMobileToProducts < ActiveRecord::Migration
  def change
    add_column :categories, :isMobile, :boolean , :default => false
  end
end
