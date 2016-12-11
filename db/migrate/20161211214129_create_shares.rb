class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
    	t.integer :discount
    	t.string :image
    	t.boolean :active, default: false
    end
  end
end
