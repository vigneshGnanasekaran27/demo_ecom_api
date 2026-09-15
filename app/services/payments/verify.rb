module Payments
  # Handles the frontend's post-Checkout callback (PAYMENT-01). Never trusts
  # the callback alone: verifies the HMAC signature, then independently
  # fetches the payment from Razorpay's API and re-checks its amount against
  # order.total_cents server-side (BACKEND_RULES.md §14/§15) before
  # confirming the order. Idempotent — re-verifying an already-confirmed
  # order is a safe no-op, not an error, so a duplicate frontend call can't
  # double-process it.
  #
  # NOTE (DECISION-030): this callback-only verification is today's demo-
  # scoped confirmation path. The Razorpay webhook (the authoritative path
  # per PROJECT_CONTEXT.md §9, covering a browser closing before this runs)
  # is intentionally deferred — see the backlog in IMPLEMENTATION_PLAN.md.
  class Verify
    Result = Struct.new(:success?, :order, :error_message, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(razorpay_order_id:, razorpay_payment_id:, razorpay_signature:)
      @razorpay_order_id = razorpay_order_id
      @razorpay_payment_id = razorpay_payment_id
      @razorpay_signature = razorpay_signature
    end

    def call
      order = Order.find_by(razorpay_order_id: razorpay_order_id)
      return failure("Order not found") if order.nil?

      # Already confirmed (e.g. a duplicate verify call) — idempotent success.
      return Result.new(success?: true, order: order, error_message: nil) if order.order_status != "pending_payment"

      unless signature_valid?
        Rails.logger.warn("[Payments::Verify] invalid signature for order=#{order.id}")
        return failure("Payment verification failed")
      end

      razorpay_payment = fetch_razorpay_payment
      return failure("Unable to confirm payment with Razorpay") if razorpay_payment.nil?

      unless razorpay_payment.amount.to_i == order.total_cents
        Rails.logger.error("[Payments::Verify] amount mismatch order=#{order.id} expected=#{order.total_cents} got=#{razorpay_payment.amount}")
        return failure("Payment amount does not match order total")
      end

      unless %w[captured authorized].include?(razorpay_payment.status)
        return failure("Payment was not completed (status: #{razorpay_payment.status})")
      end

      confirm_order!(order, razorpay_payment)
      Result.new(success?: true, order: order.reload, error_message: nil)
    end

    private

    attr_reader :razorpay_order_id, :razorpay_payment_id, :razorpay_signature

    def signature_valid?
      RazorpayGateway::SignatureVerifier.valid?(
        razorpay_order_id: razorpay_order_id,
        razorpay_payment_id: razorpay_payment_id,
        razorpay_signature: razorpay_signature
      )
    end

    def fetch_razorpay_payment
      ::Razorpay::Payment.fetch(razorpay_payment_id)
    rescue ::Razorpay::Error => e
      Rails.logger.error("[Payments::Verify] fetch failed: #{e.message}")
      nil
    end

    def confirm_order!(order, razorpay_payment)
      ActiveRecord::Base.transaction do
        order.payments.create!(
          razorpay_order_id: razorpay_order_id,
          razorpay_payment_id: razorpay_payment_id,
          razorpay_signature: razorpay_signature,
          amount_cents: razorpay_payment.amount.to_i,
          status: razorpay_payment.status,
          raw_response: razorpay_payment.attributes
        )

        order.update!(
          payment_status: "successful",
          razorpay_payment_id: razorpay_payment_id,
          confirmed_at: Time.current
        )

        # ORDER-01's transition guard + audit trail — replaces the direct
        # order_status update this service used before Orders::UpdateStatus
        # existed (flagged as a "revisit" item when Phase 2 shipped). The
        # order is always "pending_payment" here (checked above), and
        # pending_payment -> confirmed is always a legal transition, so
        # failure is structurally unreachable — still logged rather than
        # silently ignored in case that ever stops being true.
        transition = Orders::UpdateStatus.call(order: order, new_status: "confirmed", note: "Payment verified via Razorpay")
        Rails.logger.error("[Payments::Verify] unexpected transition failure order=#{order.id}: #{transition.error_message}") unless transition.success?
      end
    end

    def failure(message)
      Result.new(success?: false, order: nil, error_message: message)
    end
  end
end
