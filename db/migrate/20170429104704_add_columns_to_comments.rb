class AddColumnsToComments < ActiveRecord::Migration
  def change
  	add_column :comments, :email, :string, null: false
  	add_column :comments, :phone, :string
  	add_column :comments, :order_id, :string
  end
end
