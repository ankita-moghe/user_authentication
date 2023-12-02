Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :registrations, only: [:create]

  resources :users, only: [:update] do
    collection do
      post 'login'
      put 'verify_token_for_login'
    end

    member do
      patch 'update_password'
      delete 'log_out'
      put 'verify_token'
      put 'generate_token'
    end
  end
end
