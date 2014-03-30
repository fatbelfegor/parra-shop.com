class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
    	t.column :order_id,   :integer, :null => false
      t.column :product_id,   :integer, :null => false
      t.column :quantity,   :integer, :null => false
      t.column :price, :decimal , :precision => 18, :scale => 2, :default => 0, :null => false
      t.column :size,   :string
      t.column :color,   :string
      t.column :option,   :string

      t.timestamps
    end
  end
end
