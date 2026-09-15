# Named RazorpayGateway (not `Razorpay`) deliberately: naming our own
# app/services namespace identically to the `razorpay` gem's top-level
# module causes Zeitwerk to take reload-ownership of that whole constant —
# on the next code reload it removes and re-autoloads the entire `Razorpay`
# namespace, wiping out the gem's own already-loaded classes
# (Razorpay::Error, Razorpay::Order, ...) along with it. Hit this exact bug
# during PAYMENT-01 verification (NameError: uninitialized constant
# Razorpay::Error) — this rename is the fix, not a style preference.
module RazorpayGateway
  # Calls Razorpay's Orders API for a given local Order and stores the
  # returned razorpay_order_id (PAYMENT-01). Amount is always taken from the
  # local order's own total_cents — never from a client-supplied value.
  class CreateOrder
    Result = Struct.new(:success?, :razorpay_order_id, :error_message, keyword_init: true)

    def self.call(order)
      new(order).call
    end

    def initialize(order)
      @order = order
    end

    def call
      response = ::Razorpay::Order.create(
        amount: order.total_cents,
        currency: "INR",
        receipt: order.order_number,
        payment_capture: 1
      )

      order.update!(razorpay_order_id: response.id)
      Result.new(success?: true, razorpay_order_id: response.id, error_message: nil)
    rescue ::Razorpay::Error => e
      Rails.logger.error("[RazorpayGateway::CreateOrder] order=#{order.id} failed: #{e.message}")
      Result.new(success?: false, razorpay_order_id: nil, error_message: "Unable to start payment. Please try again.")
    end

    private

    attr_reader :order
  end
end
