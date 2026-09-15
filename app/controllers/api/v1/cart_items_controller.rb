module Api
  module V1
    # Ownership is enforced structurally: every action scopes through
    # `current_cart.cart_items`, which is resolved server-side from the
    # request's own auth/guest identity (BaseController#current_cart) — a
    # client can never supply a cart id, so a cross-cart item id simply
    # 404s via the shared ActiveRecord::RecordNotFound rescue (CART-05/06's
    # ownership requirement, satisfied without a separate Pundit policy).
    class CartItemsController < BaseController
      before_action :set_product, only: [ :create ]
      before_action :set_cart_item, only: [ :update, :destroy ]

      # POST /api/v1/cart/items
      def create
        quantity = params[:quantity].to_i
        quantity = 1 if quantity < 1

        return render_out_of_stock unless @product.status == "active" && @product.stock_quantity.positive?

        item = current_cart.cart_items.find_by(product_id: @product.id)
        new_quantity = (item&.quantity || 0) + quantity

        return render_insufficient_stock if new_quantity > @product.stock_quantity

        item ||= current_cart.cart_items.build(product: @product)
        item.quantity = new_quantity
        item.unit_price_cents = @product.effective_price_cents

        if item.save
          render json: { data: CartSerializer.new(current_cart.reload).as_json }, status: :created
        else
          render_validation_error(item)
        end
      end

      # PATCH /api/v1/cart/items/:id
      def update
        quantity = params[:quantity].to_i

        return render_validation_error_message("Quantity must be at least 1") if quantity < 1
        return render_insufficient_stock if quantity > @cart_item.product.stock_quantity

        @cart_item.quantity = quantity
        @cart_item.unit_price_cents = @cart_item.product.effective_price_cents

        if @cart_item.save
          render json: { data: CartSerializer.new(current_cart.reload).as_json }
        else
          render_validation_error(@cart_item)
        end
      end

      # DELETE /api/v1/cart/items/:id
      def destroy
        @cart_item.destroy
        render json: { data: CartSerializer.new(current_cart.reload).as_json }
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def set_cart_item
        @cart_item = current_cart.cart_items.find(params[:id])
      end

      def render_out_of_stock
        render json: {
          error: { code: "OUT_OF_STOCK", message: "This product is currently out of stock" }
        }, status: :unprocessable_entity
      end

      def render_insufficient_stock
        render json: {
          error: { code: "INSUFFICIENT_STOCK", message: "Not enough stock available for the requested quantity" }
        }, status: :unprocessable_entity
      end

      def render_validation_error_message(message)
        render json: { error: { code: "VALIDATION_ERROR", message: message } }, status: :unprocessable_entity
      end
    end
  end
end
