class CreateBanner < ActiveRecord::Migration
  def change
    create_table :banners do |t|
    	t.string :image
    	t.string :url
    end
  end
end
