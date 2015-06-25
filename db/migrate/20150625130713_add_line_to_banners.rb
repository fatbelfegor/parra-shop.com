class AddLineToBanners < ActiveRecord::Migration
  def change
  	add_column :banners, :second_line, :boolean, default: false
  	add_column :banners, :third_line, :boolean, default: false
  end
end
