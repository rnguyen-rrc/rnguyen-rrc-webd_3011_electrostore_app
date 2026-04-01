class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price_at_purchase
      t.decimal :subtotal
      t.decimal :hst_rate
      t.decimal :pst_rate
      t.decimal :hst_amount
      t.decimal :pst_amount
      t.decimal :line_total

      t.timestamps
    end
  end
end
