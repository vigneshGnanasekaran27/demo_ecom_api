# Disabled in test: request specs/system tests fire many rapid requests at
# these same endpoints, and a shared in-memory throttle store would produce
# false-positive 429s unrelated to whatever the test is actually checking.
Rack::Attack.enabled = !Rails.env.test?

class Rack::Attack
  throttle("auth/login/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  throttle("auth/register/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/auth/register" && req.post?
  end

  self.throttled_responder = lambda do |_request|
    body = { error: { code: "RATE_LIMITED", message: "Too many requests. Please try again later." } }
    [ 429, { "Content-Type" => "application/json" }, [ body.to_json ] ]
  end
end
