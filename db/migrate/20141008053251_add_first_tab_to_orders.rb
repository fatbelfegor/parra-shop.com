class AddFirstTabToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :salon, :string
    add_column :orders, :salon_tel, :string
    add_column :orders, :manager, :string
    add_column :orders, :manager_tel, :string
    add_column :orders, :addr_metro, :string
    add_column :orders, :addr_staircase, :string
    add_column :orders, :addr_floor, :string
    add_column :orders, :addr_code, :string
    add_column :orders, :addr_elevator, :string
    add_column :orders, :deliver_type, :string
    add_column :orders, :deliver_cost, :decimal
    add_column :orders, :prepayment_date, :string
    add_column :orders, :prepayment_sum, :decimal
    add_column :orders, :doppayment_date, :string
    add_column :orders, :doppayment_sum, :decimal
    add_column :orders, :finalpayment_date, :string
    add_column :orders, :finalpayment_sum, :decimal
    add_column :orders, :payment_type, :string
    add_column :orders, :credit_sum, :decimal
    add_column :orders, :credit_month, :integer
    add_column :orders, :credit_procent, :decimal
    add_column :orders, :deliver_date, :string
  end
end
