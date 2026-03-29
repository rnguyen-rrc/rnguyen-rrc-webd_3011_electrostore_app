class RemoveAuditFieldsFromCategories < ActiveRecord::Migration[7.0]
  def change
    remove_column :categories, :created_by, :integer
    remove_column :categories, :updated_by, :integer
  end
end