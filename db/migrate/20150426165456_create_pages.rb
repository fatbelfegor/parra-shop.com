class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
    	t.string :name
    	t.string :url
    	t.string :seo_title
    	t.string :seo_keywords
    	t.text :seo_description
    	t.text :description, limit: 16777215
    end
  end
end
