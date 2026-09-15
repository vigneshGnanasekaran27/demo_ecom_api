module Api
  module V1
    # GET /api/v1/cart — returns (creating if absent) the current cart for
    # the authenticated user or guest session (CART-01). No authentication
    # required: browsing/adding to cart without an account is a hard
    # requirement (AI_RULES.md §16).
    class CartController < BaseController
      def show
        render json: { data: CartSerializer.new(current_cart).as_json }
      end
    end
  end
end
