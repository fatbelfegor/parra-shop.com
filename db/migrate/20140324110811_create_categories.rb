class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.integer :position
      t.string :header
      t.text :images
      t.integer :parent_id
      t.string :s_title
      t.string :s_description
      t.string :s_keyword
      t.string :s_name
      t.string :scode

      t.timestamps
    end
  end
end
