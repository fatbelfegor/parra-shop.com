class AddSeoTitle2ToProducts < ActiveRecord::Migration
  def change
    add_column :products, :seo_title2, :string
  end
end
