class CreateTextures < ActiveRecord::Migration
  def change
    create_table :textures do |t|
    	t.belongs_to :color
    	t.string :name
    	t.string :scode
    	t.string :image
    	t.decimal :price, precision: 18, scale: 2, default: 0.0
    end
  end
end
