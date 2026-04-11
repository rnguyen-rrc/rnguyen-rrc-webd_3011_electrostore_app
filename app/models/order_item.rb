class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true,
                       numericality: { only_integer: true, greater_than: 0 }

  validates :price_at_purchase, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hst_amount", "hst_rate", "id", "id_value", "line_total", "order_id", "price_at_purchase", "product_id", "pst_amount", "pst_rate", "quantity", "subtotal", "updated_at"]
  end                  
end
