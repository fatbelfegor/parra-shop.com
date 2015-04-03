class CreateSizes < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
    	t.belongs_to :product
    	t.string :name
    	t.string :scode
    	t.decimal :price, precision: 18, scale: 2, default: 0.0
    end
  end
end
