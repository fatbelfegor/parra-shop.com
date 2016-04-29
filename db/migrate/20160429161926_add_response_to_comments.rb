class AddResponseToComments < ActiveRecord::Migration
  def change
    add_column :comments, :response, :text
  end
end
