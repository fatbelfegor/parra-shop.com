class CreateProducts < ActiveRecord::Migration
  def change
		create_table :products do |t|
			t.integer :category_id,
			t.string :scode,
			t.string :name,
			t.text :description,
			t.text :images,
			t.text :shortdesk,
			t.boolean :delemiter,
			t.boolean :invisible,
			t.boolean :main,
			t.boolean :action,
			t.boolean :best,
			t.integer :position,
			t.string :s_title,
			t.string :s_description,
			t.string :s_keyword,
			t.string :s_imagealt,

      t.timestamps
    end
  end
end
