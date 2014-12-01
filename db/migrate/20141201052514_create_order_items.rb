class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.string :articul
      t.integer :color
      t.string :color_name
      t.decimal :color_price
      t.integer :count
      t.integer :product_id
      t.string :images
      t.string :name
      t.integer :option
      t.string :optionName
      t.decimal :optionPrice
      t.decimal :price
      t.string :scode
      t.integer :size
      t.string :sizeName
      t.decimal :sizePrice
      t.integer :texture
      t.string :textureName
      t.decimal :texturePrice

      t.timestamps
    end
  end
end
