class AddPrcolorsAndProptionsToPrsizes < ActiveRecord::Migration
  def change
    add_column :prcolors, :prsize_id, :integer
    add_column :proptions, :prsize_id, :integer
    add_index :prcolors, :prsize_id
    add_index :proptions, :prsize_id
  end
end
