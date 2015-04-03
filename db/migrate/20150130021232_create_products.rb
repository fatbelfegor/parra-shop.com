class CreateProducts < ActiveRecord::Migration
	def change
		create_table :products do |t|
			t.belongs_to "category"
			t.string "scode", null: false
			t.string "name", null: false
			t.text "description"
			t.text "shortdesk"
			t.boolean "delemiter"
			t.boolean "invisible"
			t.boolean "main"
			t.boolean "action"
			t.boolean "best"
			t.integer "position"
			t.string "seo_title"
			t.string "seo_description"
			t.string "seo_keywords"
			t.string "seo_imagealt"
			t.decimal "price", precision: 18, scale: 2, default: 0.0
			t.text "seo_text"
			t.decimal "old_price", precision: 18, scale: 2, default: 0.0
			t.string "seo_title2"
			t.integer "subcategory_id"
			t.string "article"
			t.integer "extension_id"
		end

		add_index :products, :scode, unique: true
	end
end