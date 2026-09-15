class User < ApplicationRecord
  has_secure_password

  # Matches the DB-level check constraint from DB-02 (DECISION-011/012) exactly.
  enum :role, {
    customer: "customer",
    admin: "admin",
    manager: "manager",
    warehouse: "warehouse",
    dispatch: "dispatch",
    delivery: "delivery"
  }, default: "customer"

  scope :customers, -> { where(role: :customer) }
  scope :staff, -> { where.not(role: :customer) }

  before_validation { self.email = email.to_s.downcase.strip }

  validates :email, presence: true,
                     uniqueness: { case_sensitive: false },
                     format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
end
