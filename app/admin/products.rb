ActiveAdmin.register Product do

  include Rails.application.routes.url_helpers

  permit_params :name, :description, :price, :stock_quantity, :image, :remove_image, category_ids: []

  remove_filter :product_categories
  remove_filter :categories

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :stock_quantity

    column :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), size: "60x60"
      end
    end

    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :categories,
  input_html: {
    size: 5,
    style: "width: 300px;"
  }
      f.input :price
      f.input :stock_quantity

      f.input :image,
        as: :file,
        hint: (
          if f.object.image.attached?
            image_tag url_for(f.object.image), width: 150
          end
        )

      f.input :remove_image, as: :boolean, label: "Remove Image"
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :stock_quantity

      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), width: 150
        end
      end
    end
  end

end