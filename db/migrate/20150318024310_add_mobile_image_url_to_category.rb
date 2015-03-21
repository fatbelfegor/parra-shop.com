class AddMobileImageUrlToCategory < ActiveRecord::Migration
  def change
   add_column :categories, :mobile_image_url, :string
  end
end
