class AddImagesToPrcolors < ActiveRecord::Migration
  def change
    add_column :prcolors, :images, :string
  end
end
