# Anonymous visitor identity (DECISION-007) — never a fabricated customer
# identity, only a random opaque token. email/phone stay nil unless the
# visitor voluntarily provides them (e.g. at checkout).
class GuestSession < ApplicationRecord
  belongs_to :user, optional: true

  validates :token, presence: true, uniqueness: true
  validates :first_seen_at, presence: true
  validates :last_seen_at, presence: true
end
