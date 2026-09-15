module Payments
  # Records a real, attempted-and-rejected Razorpay payment (card declined,
  # etc.) — called from the frontend's `payment.failed` handler. This is
  # the distinction the admin console relies on: an order the customer
  # never even tried to pay for (still pending_payment/payment_status
  # "pending") is an abandoned cart, not a failed order; an order where a
  # payment was actually submitted and rejected (payment_status "failed")
  # is a real order worth showing to admin. Idempotent no-op if the order
  # already moved past pending_payment (e.g. a stale/duplicate callback
  # arriving after a retry succeeded).
  class MarkFailed
    Result = Struct.new(:success?, :order, :error_message, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(razorpay_order_id:, razorpay_payment_id: nil, reason: nil)
      @razorpay_order_id = razorpay_order_id
      @razorpay_payment_id = razorpay_payment_id
      @reason = reason
    end

    def call
      order = Order.find_by(razorpay_order_id: razorpay_order_id)
      return failure("Order not found") if order.nil?

      return Result.new(success?: true, order: order, error_message: nil) if order.order_status != "pending_payment"

      ActiveRecord::Base.transaction do
        order.payments.create!(
          razorpay_order_id: razorpay_order_id,
          razorpay_payment_id: razorpay_payment_id,
          amount_cents: order.total_cents,
          status: "failed",
          raw_response: { reason: reason }.compact
        )
        order.update!(payment_status: "failed")
      end

      Result.new(success?: true, order: order.reload, error_message: nil)
    end

    private

    attr_reader :razorpay_order_id, :razorpay_payment_id, :reason

    def failure(message)
      Result.new(success?: false, order: nil, error_message: message)
    end
  end
end
