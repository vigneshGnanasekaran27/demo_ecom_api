module Auth
  # Signs/verifies the JWTs carried in the httpOnly access/refresh cookies
  # (DECISION-014). Not for direct use outside the auth flow — controllers go
  # through AUTH-05/07/08's cookie helpers instead.
  class TokenService
    ALGORITHM = "HS256"

    class << self
      def encode(payload, expires_in:)
        JWT.encode(payload.merge(exp: expires_in.from_now.to_i), secret, ALGORITHM)
      end

      # Returns the decoded payload (with indifferent access) or nil if the
      # token is missing, expired, or its signature doesn't verify.
      def decode(token)
        return nil if token.blank?

        decoded, = JWT.decode(token, secret, true, algorithm: ALGORITHM)
        decoded.with_indifferent_access
      rescue JWT::DecodeError
        nil
      end

      private

      def secret
        Rails.application.credentials.jwt_secret ||
          raise("Missing jwt_secret in Rails credentials — see AUTH-03/DECISION-018")
      end
    end
  end
end
