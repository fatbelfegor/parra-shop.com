class AddColumnsToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :price, :decimal , :precision => 18, :scale => 2, :default => 0
  end
end
