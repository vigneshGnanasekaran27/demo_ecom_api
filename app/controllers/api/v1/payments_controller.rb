module Api
  module V1
    class PaymentsController < BaseController
      # POST /api/v1/payments/verify
      #
      # No authentication required — a guest checkout must be able to
      # verify its own payment too. Ownership isn't a concern here: the
      # request must supply a real, signature-valid Razorpay payment tied to
      # a specific local order via razorpay_order_id (PAYMENT-01).
      def verify
        result = Payments::Verify.call(
          razorpay_order_id: params[:razorpay_order_id],
          razorpay_payment_id: params[:razorpay_payment_id],
          razorpay_signature: params[:razorpay_signature]
        )

        if result.success?
          render json: { data: OrderSerializer.new(result.order).as_json }
        else
          render json: {
            error: { code: "PAYMENT_VERIFICATION_FAILED", message: result.error_message }
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/payments/failed
      #
      # Called when Razorpay Checkout reports a rejected payment attempt —
      # distinguishes a real failed order from a customer who never
      # attempted payment at all (see Payments::MarkFailed).
      def failed
        result = Payments::MarkFailed.call(
          razorpay_order_id: params[:razorpay_order_id],
          razorpay_payment_id: params[:razorpay_payment_id],
          reason: params[:reason]
        )

        if result.success?
          render json: { data: OrderSerializer.new(result.order).as_json }
        else
          render json: { error: { code: "ORDER_NOT_FOUND", message: result.error_message } }, status: :not_found
        end
      end
    end
  end
end
