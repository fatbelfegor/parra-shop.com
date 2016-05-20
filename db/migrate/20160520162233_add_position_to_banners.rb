class AddPositionToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :position, :integer, default: 0
  end
end
