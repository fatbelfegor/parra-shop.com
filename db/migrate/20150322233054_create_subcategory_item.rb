class CreateSubcategoryItem < ActiveRecord::Migration
  def change
    create_table :subcategory_items do |t|
    	t.string :image
    	t.text :description
    	t.belongs_to :subcategory
    end
  end
end
