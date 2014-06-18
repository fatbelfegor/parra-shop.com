class AddColumnToOrderItems < ActiveRecord::Migration
  def change
    add_reference :order_items, :order, index: true
  end
end
