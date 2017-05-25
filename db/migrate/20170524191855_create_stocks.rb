class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
    	t.string :color
    	t.string :name
    end

    add_column :products, :stock_id, :integer, index: true
  end
end
