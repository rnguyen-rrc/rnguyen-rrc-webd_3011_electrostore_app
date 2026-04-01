class CreateProvinces < ActiveRecord::Migration[8.1]
  def change
    create_table :provinces do |t|
      t.string :name
      t.decimal :hst_rate
      t.decimal :pst_rate
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
