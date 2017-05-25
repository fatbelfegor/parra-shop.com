class AddCustomStockToProducts < ActiveRecord::Migration
  def change
    add_column :products, :custom_stock, :boolean, default: false
  end
end
