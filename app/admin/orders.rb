# ActiveAdmin.register Order do
#   permit_params :user_id, :shipping_street, :shipping_city,
#                 :shipping_province_id, :shipping_postal_code,
#                 :subtotal, :hst_amount, :pst_amount,
#                 :total_amount, :status, :shipped_at, :delivered_at

#   index do
#     selectable_column
#     id_column
#     column :user
#     column :status
#     column :total_amount
#     column :created_at
#     actions
#   end
# end