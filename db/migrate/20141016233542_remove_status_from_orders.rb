class RemoveStatusFromOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :status
    add_column :orders, :status_id, :integer, index: true
  end
end
