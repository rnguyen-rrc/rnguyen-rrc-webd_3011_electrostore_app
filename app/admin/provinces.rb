ActiveAdmin.register Province do
  permit_params :name, :hst_rate, :pst_rate

  # ------------------------
  # INDEX PAGE
  # ------------------------
  index do
    id_column
    column :name

    column "HST / GST" do |province|
      "#{(province.hst_rate * 100).round(2)}%"
    end

    column "PST" do |province|
      "#{(province.pst_rate * 100).round(2)}%"
    end

    column :created_at

    actions
  end

  # ------------------------
  # SHOW PAGE
  # ------------------------
  show do
    attributes_table do
      row :id
      row :name

      row("HST / GST") do |province|
        "#{(province.hst_rate * 100).round(2)}%"
      end

      row("PST") do |province|
        "#{(province.pst_rate * 100).round(2)}%"
      end

      row :created_at
      row :updated_at
    end
  end

  # ------------------------
  # EDIT FORM
  # ------------------------
  form do |f|
    f.inputs do
      f.input :name

      f.input :hst_rate, label: "HST / GST (e.g. 0.13 for 13%)"
      f.input :pst_rate, label: "PST (e.g. 0.07 for 7%)"
    end

    f.actions
  end
end