class AddNameToPackinglistitems < ActiveRecord::Migration
  def change
    add_column :packinglistitems, :name, :string
  end
end
