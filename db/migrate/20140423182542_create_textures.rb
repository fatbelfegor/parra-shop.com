class CreateTextures < ActiveRecord::Migration
  def change
    create_table :textures do |t|
    	t.integer :prcolor_id
		t.string :scode
		t.string :name
		t.string :image
		t.decimal :price, :precision => 18, :scale => 2, :default => 0, :null => false

		t.timestamps
    end
  end
end
