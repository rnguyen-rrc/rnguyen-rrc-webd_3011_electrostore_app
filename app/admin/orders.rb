ActiveAdmin.register Order do
  permit_params :status

  # ------------------------
  # INDEX PAGE (list view)
  # ------------------------
  index do
    selectable_column
    id_column

    column "Customer" do |order|
      if order.user
        "#{order.user.first_name} #{order.user.last_name}"
      else
        "Guest"
      end
    end

    column :status

    column "Subtotal" do |order|
      number_to_currency(order.subtotal)
    end

    column "HST" do |order|
      number_to_currency(order.hst_amount)
    end

    column "PST" do |order|
      number_to_currency(order.pst_amount)
    end

    column "Total" do |order|
      number_to_currency(order.total_amount)
    end

    column :created_at

    actions
  end

  # ------------------------
  # SHOW PAGE (details)
  # ------------------------
  show do
    attributes_table do
      row :id
      row :status

      row "Customer" do |order|
        if order.user
          "#{order.user.first_name} #{order.user.last_name}"
        else
          "Guest"
        end
      end

      row :email
      row :phone

      row("Subtotal") { number_to_currency(order.subtotal) }
      row("HST")      { number_to_currency(order.hst_amount) }
      row("PST")      { number_to_currency(order.pst_amount) }
      row("Total")    { number_to_currency(order.total_amount) }

      row :created_at
    end

    panel "Order Items" do
      table_for order.order_items do
        column "Product" do |item|
          item.product.name
        end

        column :quantity

        column "Price" do |item|
          number_to_currency(item.price_at_purchase)
        end

        column "HST" do |item|
          number_to_currency(item.hst_amount)
        end

        column "PST" do |item|
          number_to_currency(item.pst_amount)
        end

        column "Line Total" do |item|
          number_to_currency(item.line_total)
        end
      end
    end
  end

  # ------------------------
  # EDIT FORM (manual change)
  # ------------------------
  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: ["new", "paid", "shipped", "cancelled"]
    end
    f.actions
  end

  # ------------------------
  # BUTTON: MARK AS SHIPPED
  # ------------------------
  member_action :mark_as_shipped, method: :patch do
    order = Order.find(params[:id])
    order.update(status: "shipped")
    redirect_to resource_path(order), notice: "Order marked as shipped"
  end

  action_item :mark_as_shipped, only: :show do
    if resource.status == "paid"
      link_to "Mark as Shipped",
        mark_as_shipped_admin_order_path(resource),
        method: :patch
    end
  end
end