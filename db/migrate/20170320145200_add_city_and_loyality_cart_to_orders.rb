class AddCityAndLoyalityCartToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :city, :string
    add_column :orders, :loyality_card, :string
  end
end
