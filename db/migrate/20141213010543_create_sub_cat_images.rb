class CreateSubCatImages < ActiveRecord::Migration
  def change
    create_table :sub_cat_images do |t|
      t.string :url
      t.text :description
      t.belongs_to :subcategory, index: true
    end
  end
end
