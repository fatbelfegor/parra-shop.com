class CreateProductFooterImages < ActiveRecord::Migration
  def change
    create_table :product_footer_images do |t|
    	t.string :image
    	t.belongs_to :product
    end
  end
end
