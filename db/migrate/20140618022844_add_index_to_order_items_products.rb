class AddIndexToOrderItemsProducts < ActiveRecord::Migration
  def change
    add_index :order_items, :product_id
  end
end
