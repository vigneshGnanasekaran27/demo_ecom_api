# See create_order.rb for why this module is named RazorpayGateway rather
# than Razorpay (Zeitwerk reload-ownership collision with the gem).
module RazorpayGateway
  # Thin wrapper around the razorpay gem's own HMAC-SHA256 verification
  # (Razorpay::Utility#verify_payment_signature) — reused rather than
  # hand-rolled per BACKEND_RULES.md §17's "no custom cryptography" spirit.
  # Never raises: callers get a plain boolean either way.
  class SignatureVerifier
    def self.valid?(razorpay_order_id:, razorpay_payment_id:, razorpay_signature:)
      ::Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: razorpay_order_id,
        razorpay_payment_id: razorpay_payment_id,
        razorpay_signature: razorpay_signature
      )
    rescue SecurityError, ::Razorpay::Error
      false
    end
  end
end
