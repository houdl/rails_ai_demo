Rails.application.routes.draw do
  root 'chats#index'

  resources :chats do
    resources :messages, only: [:create]
  end

  get '/search', to: 'searches#index', as: 'search'
  post '/search', to: 'searches#search', as: 'perform_search'
end
