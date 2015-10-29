class AddColumnsToOrderItems < ActiveRecord::Migration
  def change
  	add_column :order_items, :size_scode, :string
  	add_column :order_items, :color_scode, :string
  	add_column :order_items, :option_scode, :string
  end
end
