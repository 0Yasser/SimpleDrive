Rails.application.routes.draw do
  
  devise_for :users, path: 'v1/auth', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'v1/auth/sessions',
    registrations: 'v1/auth/registrations'
  }

  namespace :v1 do
    namespace :users do
      get 'details', to: 'users#index'
    end
    namespace :blobs do
      post '', to: 'blobs#create'
      get '/:id_or_path', to: 'blobs#index'
      # get 'blobs/delete/<id>', to: 'blobs#destroy'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
