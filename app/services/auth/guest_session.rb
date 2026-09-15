module Auth
  # Issues/resolves the guest_session_id cookie for anonymous cart-touching
  # requests (DECISION-007, CART-01). Delivered the same httpOnly cookie way
  # as the auth tokens (DECISION-014/DECISION-020) — never localStorage, and
  # never a fabricated customer identity, just an opaque random token.
  class GuestSession
    COOKIE_NAME = :guest_session_token
    EXPIRY = 90.days

    class << self
      # Returns the current guest session for this cookie jar, creating one
      # (and setting the cookie) on first touch. Reuses an existing row and
      # touches last_seen_at on subsequent requests.
      def resolve!(cookies)
        token = cookies[COOKIE_NAME]
        session = token.present? ? ::GuestSession.find_by(token: token) : nil

        if session
          session.touch(:last_seen_at)
        else
          session = create_session!
          set_cookie(cookies, session.token)
        end

        session
      end

      private

      def create_session!
        ::GuestSession.create!(
          token: SecureRandom.hex(32),
          first_seen_at: Time.current,
          last_seen_at: Time.current
        )
      end

      def set_cookie(cookies, token)
        cookies[COOKIE_NAME] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :none : :lax,
          expires: EXPIRY.from_now,
          path: "/"
        }
      end
    end
  end
end
