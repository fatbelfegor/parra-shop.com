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
      t.string :addr_street # Улица
      t.string :addr_home # Дом
      t.string :addr_block # Корпус
      t.string :addr_flat # Квартира
      # Нужно ещё: метро, подъезд, этаж, код, лифт
      t.text :comment

      t.timestamps
    end
  end
end
