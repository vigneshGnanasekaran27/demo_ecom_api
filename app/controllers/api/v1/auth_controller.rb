module Api
  module V1
    class AuthController < BaseController
      ACCESS_TOKEN_EXPIRY = 15.minutes
      REFRESH_TOKEN_EXPIRY = 30.days

      # POST /api/v1/auth/register
      def register
        user = User.new(register_params.merge(role: "customer"))

        if user.save
          issue_auth_cookies(user)
          render json: { data: UserSerializer.new(user).as_json }, status: :created
        else
          render json: {
            error: {
              code: "VALIDATION_ERROR",
              message: "Unable to register",
              details: user.errors.full_messages
            }
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.downcase.strip)

        if user&.active? && user.authenticate(params[:password].to_s)
          issue_auth_cookies(user)
          render json: { data: UserSerializer.new(user).as_json }
        else
          # Burn the same bcrypt cost even when no user was found, so response
          # time can't be used to tell "wrong password" apart from "unknown
          # email" (a timing side channel on top of the "no user-enumeration
          # hints" requirement already met by the identical error body).
          BCrypt::Password.create(params[:password].to_s) if user.nil?
          render_invalid_credentials
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        clear_auth_cookies
        head :no_content
      end

      # POST /api/v1/auth/refresh
      def refresh
        payload = Auth::TokenService.decode(cookies[:refresh_token])
        user = payload && User.find_by(id: payload[:user_id])

        if user&.active?
          issue_access_cookie(user)
          render json: { data: { status: "ok" } }
        else
          render json: {
            error: { code: "INVALID_TOKEN", message: "Invalid or expired refresh token" }
          }, status: :unauthorized
        end
      end

      private

      def register_params
        params.permit(:email, :password, :full_name, :phone)
      end

      def render_invalid_credentials
        render json: {
          error: { code: "INVALID_CREDENTIALS", message: "Invalid email or password" }
        }, status: :unauthorized
      end

      def issue_auth_cookies(user)
        issue_access_cookie(user)
        issue_refresh_cookie(user)
      end

      def issue_access_cookie(user)
        token = Auth::TokenService.encode({ user_id: user.id }, expires_in: ACCESS_TOKEN_EXPIRY)
        set_auth_cookie(:access_token, token, ACCESS_TOKEN_EXPIRY)
      end

      def issue_refresh_cookie(user)
        token = Auth::TokenService.encode({ user_id: user.id }, expires_in: REFRESH_TOKEN_EXPIRY)
        set_auth_cookie(:refresh_token, token, REFRESH_TOKEN_EXPIRY)
      end

      # SameSite=None+Secure only in production, where frontend/backend are
      # genuinely cross-domain (Vercel/Render) over HTTPS, per DECISION-014.
      # In development, SameSite=None without Secure would be silently
      # rejected by modern browsers — SameSite=Lax works fine there since
      # "site" matching ignores port, so localhost:3000 <-> localhost:3001
      # still count as the same site (see DECISION-020).
      def set_auth_cookie(name, value, expiry)
        cookies[name] = {
          value: value,
          httponly: true,
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :none : :lax,
          expires: expiry.from_now,
          path: "/"
        }
      end

      def clear_auth_cookies
        cookies.delete(:access_token, path: "/")
        cookies.delete(:refresh_token, path: "/")
      end
    end
  end
end
