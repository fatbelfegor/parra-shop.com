class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.integer :position
      t.string :header
      t.string :seo_title
      t.text :seo_description
      t.string :seo_keywords
      t.text :seo_text
      t.string :s_name
      t.string :scode
      t.decimal :commission
      t.decimal :rate
      t.string :url
      t.boolean :menu
      t.belongs_to :category, index: true
      t.boolean :isMobile, default: false
      t.string :mobile_image_url

      t.timestamps
    end
  end
end