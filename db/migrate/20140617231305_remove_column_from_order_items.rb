class RemoveColumnFromOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :order_id, :integer
  end
end
