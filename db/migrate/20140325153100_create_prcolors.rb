class CreatePrcolors < ActiveRecord::Migration
  def change
    create_table :prcolors do |t|
      t.integer :product_id
      t.string :scode
      t.string :name
      t.decimal :price, :precision => 18, :scale => 2, :default => 0, :null => false

      t.timestamps
    end
  end
end
