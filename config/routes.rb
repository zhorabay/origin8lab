Rails.application.routes.draw do
  root to: 'api/v1/users#index'

  get '/current_user', to: 'current_user#index'
  get '/search', to: 'search#search'
  match '/logout', to: 'users/sessions#destroy', via: [:get, :delete]
  post '/payments/success', to: 'payments#handle_success'

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  namespace :api do
    namespace :v1 do
      resources :carts, only: %i[create destroy]
      resources :users, only: %i[index show create update destroy]
      resources :categories, only: %i[index show create update destroy] do
        resources :courses, only: %i[index show create update destroy] do
          resources :reviews, only: %i[index show create update destroy]
          resources :course_modules, only: %i[index show create update destroy] do
            resources :lessons, only: %i[index new create show update destroy] do
              resources :comments, only: %i[index show create update destroy]
            end
          end
        end
      end
    end
  end
end
