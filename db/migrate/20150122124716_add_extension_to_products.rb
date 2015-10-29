class AddExtensionToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :extension, index: true
  end
end
