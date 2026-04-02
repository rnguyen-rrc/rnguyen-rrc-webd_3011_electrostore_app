class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province, foreign_key: :shipping_province_id
  has_many :order_items

  validates :email, presence: true
  validates :shipping_city, presence: true
  validates :shipping_province_id, presence: true
end