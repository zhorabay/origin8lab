# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://origin8lab-f.onrender.com' # Replace with your frontend URL

    resource '*', # Adjust this to match your actual API endpoints
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options],
      credentials: true
  end
end
