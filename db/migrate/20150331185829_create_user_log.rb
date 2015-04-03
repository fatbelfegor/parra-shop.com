class CreateUserLog < ActiveRecord::Migration
  def change
    create_table :user_logs do |t|
    	t.belongs_to :user
    	t.string :type
    	t.string :action
    	t.timestamp :created_at
    end
  end
end
