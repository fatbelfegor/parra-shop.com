class AddColorPositionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :color_position, :integer, default: 0
  end
end
