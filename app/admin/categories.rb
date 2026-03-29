ActiveAdmin.register Category do
  permit_params :name, :description

  remove_filter :created_by
  remove_filter :updated_by
  remove_filter :product_categories

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :created_at
      row :updated_at
    end
  end
end