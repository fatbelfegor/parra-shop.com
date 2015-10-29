class ChangeDefaultsForOrders < ActiveRecord::Migration
  def change
  	change_column_default :orders, :deliver_cost, 0
  	change_column_default :orders, :prepayment_sum, 0
  	change_column_default :orders, :doppayment_sum, 0
  	change_column_default :orders, :finalpayment_sum, 0
  	change_column_default :orders, :credit_sum, 0
  	change_column_default :orders, :credit_procent, 0
  end
end
