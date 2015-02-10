class CreateProducts < ActiveRecord::Migration
	def change
		create_table :products do |t|
			t.string :name, null: false
			t.string :scode, null: false
			t.string :article
			t.string :s_title
			t.text :description
			t.text :short_desc
			t.decimal :price, precision: 8, scale: 2, null: false
			t.decimal :old_price, precision: 8, scale: 2
			t.string :seo_title
			t.text :seo_description
			t.string :seo_keywords
			t.integer :position
			t.boolean :invisible, default: false, null: false
		end

		add_index :products, :scode, unique: true
	end
end