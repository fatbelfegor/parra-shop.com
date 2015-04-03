class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
    	t.belongs_to :size
    	t.string :name
    	t.string :scode
    	t.decimal :price, precision: 18, scale: 2, default: 0.0
    end
  end
end
