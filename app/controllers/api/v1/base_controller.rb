module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      # Sets ActiveStorage::Current.url_options from the current request so
      # ProductImage/Product serializers can call `image.blob.url` — needed
      # for the Disk service (local dev, DECISION-025); auto-included in
      # ActionController::Base browser apps but not in this API-only app.
      include ActiveStorage::SetCurrent

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      # Resolves the current user from the access-token cookie. Returns nil
      # for a missing/expired/tampered token, an unknown user id, or a
      # deactivated account — an inactive user is never "authenticated",
      # even with an otherwise-valid token.
      def current_user
        return @current_user if defined?(@current_user)

        payload = Auth::TokenService.decode(cookies[:access_token])
        user = payload && User.find_by(id: payload[:user_id])
        @current_user = user&.active? ? user : nil
      end

      def authenticate_request!
        return if current_user

        render json: {
          error: { code: "UNAUTHENTICATED", message: "Authentication required" }
        }, status: :unauthorized
      end

      # For endpoints that gate purely on role rather than resource ownership
      # (e.g. "only managers may reach this action"). Call authenticate_request!
      # first if the endpoint should also reject anonymous requests — this
      # helper only checks role, so an unauthenticated current_user (nil) is
      # correctly treated as not matching any role.
      def authorize_role!(*roles)
        allowed = roles.map(&:to_s)
        return if current_user && allowed.include?(current_user.role)

        render_forbidden
      end

      # Resolves (creating if absent) the active cart for the current
      # identity — the logged-in user if authenticated, otherwise the guest
      # session (issuing its cookie on first touch, CART-01/DECISION-007).
      # This is the only way any controller should reach "the current
      # cart" — never via a client-supplied cart id — so ownership is true
      # by construction and a cross-cart item lookup simply 404s.
      def current_cart
        return @current_cart if defined?(@current_cart)

        @current_cart = if current_user
          Cart.active.find_or_create_by!(user: current_user)
        else
          guest_session = Auth::GuestSession.resolve!(cookies)
          Cart.active.find_or_create_by!(guest_session_id: guest_session.id)
        end
      end

      # Scopes orders to the current identity (ORDER-02) — same "resolve
      # from the request's own identity, never a client param" pattern as
      # current_cart, so ownership is structural rather than a separate
      # Pundit check. Unlike current_cart, this never creates a guest
      # session — an anonymous visitor with no existing session cookie
      # simply has no orders to see (Order.none), rather than fabricating
      # one just to answer a read.
      def current_order_scope
        if current_user
          Order.where(user: current_user)
        else
          token = cookies[:guest_session_token]
          session = token.present? ? GuestSession.find_by(token: token) : nil
          session ? Order.where(guest_session_id: session.id) : Order.none
        end
      end

      private

      def render_forbidden
        render json: {
          error: { code: "FORBIDDEN", message: "You are not authorized to perform this action" }
        }, status: :forbidden
      end

      def render_not_found
        render json: {
          error: { code: "NOT_FOUND", message: "The requested resource could not be found" }
        }, status: :not_found
      end

      def render_validation_error(record)
        render json: {
          error: { code: "VALIDATION_ERROR", message: "Unable to save", details: record.errors.full_messages }
        }, status: :unprocessable_entity
      end
    end
  end
end
