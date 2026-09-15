# Supports both guest and logged-in ownership (FRONTEND_RULES.md §8,
# AI_RULES.md §16) — exactly one of user/guest_session is ever set.
class Cart < ApplicationRecord
  VALID_STATUSES = %w[active abandoned converted].freeze

  belongs_to :user, optional: true
  belongs_to :guest_session, optional: true
  has_many :cart_items, dependent: :destroy

  validates :status, inclusion: { in: VALID_STATUSES }
  validate :exactly_one_owner

  scope :active, -> { where(status: "active") }

  private

  def exactly_one_owner
    owners = [ user_id, guest_session_id ].compact
    errors.add(:base, "must belong to exactly one of user or guest session") unless owners.size == 1
  end
end
