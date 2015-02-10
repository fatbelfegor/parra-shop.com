class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :scode
      t.belongs_to :category, index: true

      t.timestamps null: false
    end
    add_foreign_key :categories, :categories
  end
end
