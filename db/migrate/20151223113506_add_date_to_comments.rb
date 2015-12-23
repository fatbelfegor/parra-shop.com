class AddDateToComments < ActiveRecord::Migration
  def change
    add_column :comments, :date, :timestamp
  end
end
