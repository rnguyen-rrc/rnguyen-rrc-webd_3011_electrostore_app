class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province, foreign_key: :shipping_province_id
  has_many :order_items

  # ------------------------
  # PRESENCE VALIDATIONS
  # ------------------------
  validates :first_name, :last_name, presence: true
  validates :email, :phone, presence: true
  validates :shipping_street, :shipping_city, :shipping_postal_code, presence: true
  validates :shipping_province_id, presence: true

  validates :subtotal, :hst_amount, :pst_amount, :total_amount, presence: true

  # ------------------------
  # FORMAT VALIDATIONS
  # ------------------------

  # Email format
  validates :email,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "must be a valid email address"
    }

  # Phone (digits only, 10–15 digits)
  validates :phone,
    format: {
      with: /\A\d{10,15}\z/,
      message: "must be 10-15 digits"
    }

  # Canadian postal code (simple version)
  validates :shipping_postal_code,
    format: {
      with: /\A[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\z/,
      message: "must be a valid postal code"
    }

  # ------------------------
  # NUMERICAL VALIDATIONS
  # ------------------------
  validates :subtotal, :hst_amount, :pst_amount, :total_amount,
    numericality: { greater_than_or_equal_to: 0 }

  # ------------------------
  # STATUS VALIDATION
  # ------------------------
  validates :status,
    inclusion: {
      in: %w[new paid shipped cancelled],
      message: "%{value} is not a valid status"
    }

  # ------------------------
  # CUSTOM VALIDATION
  # ------------------------
  validate :total_must_match_breakdown

  def total_must_match_breakdown
    expected_total = subtotal.to_f + hst_amount.to_f + pst_amount.to_f

    if total_amount.to_f.round(2) != expected_total.round(2)
      errors.add(:total_amount, "does not match subtotal + taxes")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map(&:name).map(&:to_s)
  end
end