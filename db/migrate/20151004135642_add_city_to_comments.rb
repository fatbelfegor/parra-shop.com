class AddCityToComments < ActiveRecord::Migration
  def change
    add_column :comments, :city, :string
  end
end
