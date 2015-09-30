class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :title
      t.text :body
      t.string :author
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
