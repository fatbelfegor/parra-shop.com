class CreatePackinglistitems < ActiveRecord::Migration
  def change
    create_table :packinglistitems do |t|
      t.integer :packinglist_id, index: true
      t.integer :product_id, index: true
      t.string :product_name_article
      t.integer :amount
      t.decimal :price
      t.string :name
    end
  end
end