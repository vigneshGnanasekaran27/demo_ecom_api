# Be sure to restart your server when you modify this file.

# Only the actual frontend origin is ever allowed — never a wildcard.
# Locally that's the Next.js dev server; in production it's FRONTEND_URL
# (the deployed Vercel origin), set as a real env var on Render.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV["FRONTEND_URL"].presence || "http://localhost:3000"

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
