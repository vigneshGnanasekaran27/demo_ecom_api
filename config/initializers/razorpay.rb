# Test-mode keys locally, live keys in production — both via plain env vars
# (DECISION-018), never hardcoded. Blank locally is tolerated (Razorpay-
# dependent requests will fail with a clear upstream error rather than the
# app failing to boot) so the rest of the app remains usable before real
# test-mode credentials are configured.
Razorpay.setup(ENV["RAZORPAY_KEY_ID"], ENV["RAZORPAY_KEY_SECRET"])
