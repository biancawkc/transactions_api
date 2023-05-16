Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: redirect('/accounts')
  
  get '/reset', to: 'accounts#reset'
  get '/balance/:account_id', to: 'accounts#balance'
  post '/event', to: 'accounts#event'
end
