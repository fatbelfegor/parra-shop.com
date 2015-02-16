class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
		t.column :product_id, :integer, null: false, index: true
		t.column :quantity, :integer, null: false
		t.column :price, :decimal , precision: 18, scale: 2, default: 0, null: false
		t.column :size, :string
		t.column :color, :string
		t.column :option, :string
		t.belongs_to :order
  		t.string :size_scode
  		t.string :color_scode
  		t.string :option_scode
  		t.decimal :discount, precision: 6, scale: 2, default: 0

		t.timestamps
    end
  end
end
