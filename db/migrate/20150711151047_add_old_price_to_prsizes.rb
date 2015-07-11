class AddOldPriceToPrsizes < ActiveRecord::Migration
  def change
  	add_column :prsizes, :old_price, :decimal, precision: 10, scale: 2, default: 0
  end
end
