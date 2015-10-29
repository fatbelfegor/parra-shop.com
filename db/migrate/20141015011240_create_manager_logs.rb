class CreateManagerLogs < ActiveRecord::Migration
  def change
    create_table :manager_logs do |t|
      t.string :action
      t.integer :order_id
      t.integer :order_item_id
      t.integer :user_id, index: true
      t.datetime :time
    end
  end
end
