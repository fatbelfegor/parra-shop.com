class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
    	t.belongs_to :size
    	t.string :name
    	t.string :scode
    	t.string :image
    	t.text :description
    	t.decimal :price, precision: 18, scale: 2, default: 0.0
    end
  end
end