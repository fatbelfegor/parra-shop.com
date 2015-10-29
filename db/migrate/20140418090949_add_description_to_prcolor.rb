class AddDescriptionToPrcolor < ActiveRecord::Migration
  def change
    add_column :prcolors, :description, :string
  end
end
