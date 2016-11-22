class ChangeBanners < ActiveRecord::Migration
  def change
  	remove_column :banners, :second_line
  	remove_column :banners, :third_line
  	remove_column :banners, :square_third
  	remove_column :banners, :fourth_line
  	add_column :banners, :first, :boolean, default: true
  	add_column :banners, :new, :boolean, default: false
  	add_column :banners, :hit, :boolean, default: false
  end
end