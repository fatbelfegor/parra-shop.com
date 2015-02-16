class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.string :first_name
		t.string :middle_name
		t.string :last_name
		t.string :gender
		t.string :phone
		t.string :email
		t.string :pay_type
		t.string :addr_street
		t.string :addr_home
		t.string :addr_block
		t.string :addr_flat
		t.string :salon
		t.string :salon_tel
		t.string :manager
		t.string :manager_tel
		t.string :addr_metro
		t.string :addr_staircase
		t.string :addr_floor
		t.string :addr_code
		t.string :addr_elevator
		t.string :deliver_type
		t.decimal :deliver_cost, default: 0
		t.string :prepayment_date
		t.decimal :prepayment_sum, default: 0
		t.string :doppayment_date
		t.decimal :doppayment_sum, default: 0
		t.string :finalpayment_date
		t.decimal :finalpayment_sum, default: 0
		t.string :payment_type
		t.decimal :credit_sum, default: 0
		t.integer :credit_month
		t.decimal :credit_procent, default: 0
		t.string :deliver_date
		t.text :comment
		t.belongs_to :status
		t.integer :number

		t.timestamps
    end
  end
end