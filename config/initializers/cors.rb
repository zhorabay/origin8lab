# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/api/v1/*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options],
             credentials: true
  end

  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/login',
             headers: :any,
             methods: [:post], # Adjust with the method used for login
             credentials: true
  end

  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/signup',
             headers: :any,
             methods: [:post], # Adjust with the method used for signup
             credentials: true
  end

  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/logout',
             headers: :any,
             methods: [:delete], # Adjust with the method used for logout
             credentials: true
  end

  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/search',
             headers: :any,
             methods: [:get], # Adjust with the method used for logout
             credentials: true
  end

  allow do
    origins 'https://origin8lab.com' # Replace with your frontend URL

    resource '/payments/success',
             headers: :any,
             methods: [:post], # Adjust with the method used for logout
             credentials: true
  end
end
