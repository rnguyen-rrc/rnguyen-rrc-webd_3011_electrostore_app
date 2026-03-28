class Product < ApplicationRecord

  has_one_attached :image

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "price", "stock_quantity", "image_url", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
  ["image_attachment", "image_blob"]
end

attr_accessor :remove_image

before_save :purge_image_if_requested

def purge_image_if_requested
  image.purge if remove_image == "1"
end

end