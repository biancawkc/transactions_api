Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/accounts/reset', to: 'accounts#reset'
  get '/accounts/balance/:account_id', to: 'accounts#balance'
  post '/accounts/event', to: 'accounts#event'
end
