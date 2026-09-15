module Api
  module V1
    class OrdersController < BaseController
      DEFAULT_PER_PAGE = 20

      # GET /api/v1/orders
      #
      # The current user's own orders (or the current guest session's, if
      # not logged in), most recent first, paginated (ORDER-02). Ownership
      # is structural via current_order_scope — never a client-supplied
      # filter — so there's nothing here for a Pundit policy to add.
      def index
        page = [ params[:page].to_i, 1 ].max
        per_page = params[:per_page].present? ? params[:per_page].to_i.clamp(1, 100) : DEFAULT_PER_PAGE

        scope = current_order_scope.order(created_at: :desc)
        total = scope.count
        orders = scope.offset((page - 1) * per_page).limit(per_page).includes(:order_items, :status_histories)

        render json: {
          data: orders.map { |order| OrderSerializer.new(order).as_json },
          meta: { page: page, per_page: per_page, total: total }
        }
      end

      # GET /api/v1/orders/:id
      def show
        order = current_order_scope.find(params[:id])
        render json: { data: OrderSerializer.new(order).as_json }
      end

      # POST /api/v1/orders
      #
      # Creates the order from the current cart (guest or logged-in, CART-01)
      # via Orders::Create, then immediately creates the matching Razorpay
      # order (PAYMENT-01) so the frontend gets everything it needs to open
      # Razorpay Checkout in one round trip.
      def create
        result = Orders::Create.call(cart: current_cart, shipping_params: shipping_params)

        return render_order_error(result.error_message) unless result.success?

        order = result.order
        razorpay_result = RazorpayGateway::CreateOrder.call(order)

        unless razorpay_result.success?
          # The local order already exists (pending_payment) — leave it as
          # is so the customer can retry payment rather than losing the
          # order; surface the Razorpay-side failure clearly instead of
          # silently pretending checkout succeeded.
          return render json: {
            error: { code: "PAYMENT_INIT_FAILED", message: razorpay_result.error_message }
          }, status: :bad_gateway
        end

        render json: {
          data: OrderSerializer.new(order.reload).as_json.merge(
            razorpay: {
              key_id: ENV["RAZORPAY_KEY_ID"],
              order_id: razorpay_result.razorpay_order_id,
              amount: order.total_cents,
              currency: "INR"
            }
          )
        }, status: :created
      end

      private

      def shipping_params
        params.require(:shipping).permit(:name, :phone, :line1, :line2, :city, :state, :postal_code, :landmark, :country)
      end

      def render_order_error(message)
        render json: { error: { code: "ORDER_CREATION_FAILED", message: message } }, status: :unprocessable_entity
      end
    end
  end
end
