class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :stripe_payment_id
      t.string :payment_method
      t.string :status
      t.datetime :payment_date_time

      t.timestamps
    end
  end
end
