class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user
      t.string :shipping_street
      t.string :shipping_city
      t.integer :shipping_province_id
      t.string :shipping_postal_code
      t.decimal :subtotal
      t.decimal :hst_amount
      t.decimal :pst_amount
      t.decimal :total_amount
      t.string :status

      t.timestamps
    end
  end
end