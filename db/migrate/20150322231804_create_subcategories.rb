class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
    	t.string :name
    	t.text :description
    	t.belongs_to :category
    end
  end
end
