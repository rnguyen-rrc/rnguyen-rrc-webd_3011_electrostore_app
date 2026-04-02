class Province < ApplicationRecord
  has_many :users
  has_many :orders, foreign_key: :shipping_province_id

  validates :name, presence: true, uniqueness: true

  validates :gst_rate, presence: true,
                       numericality: { greater_than_or_equal_to: 0 }

  validates :pst_rate, presence: true,
                       numericality: { greater_than_or_equal_to: 0 }
end