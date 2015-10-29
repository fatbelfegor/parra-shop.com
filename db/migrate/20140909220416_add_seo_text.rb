class AddSeoText < ActiveRecord::Migration
  def change
  	add_column :products, :seo_text, :text
  	add_column :categories, :seo_text, :text
  end
end
