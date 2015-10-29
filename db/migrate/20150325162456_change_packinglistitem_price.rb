class ChangePackinglistitemPrice < ActiveRecord::Migration
  def change
  	change_column :packinglistitems, :price, :decimal, precision: 18, scale: 2
  end
end
