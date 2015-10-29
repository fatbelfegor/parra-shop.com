class CreatePackinglists < ActiveRecord::Migration
  def change
    create_table :packinglists do |t|
      t.string :doc_number
      t.date :date
      t.string :user
    end
  end
end
