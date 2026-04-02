class User < ApplicationRecord
  belongs_to :province
  has_many :orders

  has_secure_password

  before_create :set_default_role
  private

  def set_default_role
    self.role ||= "user"
  end

  validates :role, inclusion: { in: ["user", "admin"] }
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :postal_code, format: { with: /\A[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d\z/ }
end