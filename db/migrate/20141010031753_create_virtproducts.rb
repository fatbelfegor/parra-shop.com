class CreateVirtproducts < ActiveRecord::Migration
  def change
    create_table :virtproducts do |t|
      t.text :text
      t.decimal :price, precision: 18, scale: 2, default: 0, null: false
      t.integer :order_id
    end
  end
end
