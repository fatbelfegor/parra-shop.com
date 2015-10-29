class AddDiscountToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :discount, :decimal, default: 0
  end
end
