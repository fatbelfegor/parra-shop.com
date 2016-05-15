class AddNextLineToBanners < ActiveRecord::Migration
  def change
  	add_column :banners, :square_third, :boolean, default: false
  	add_column :banners, :fourth_line, :boolean, default: false
  end
end
