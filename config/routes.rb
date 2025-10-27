Rails.application.routes.draw do
  root 'chats#index'

  resources :chats do
    resources :messages, only: [:create]
  end

  get '/search', to: 'searches#index', as: 'search'
  post '/search', to: 'searches#search', as: 'perform_search'

  # Computer Use API routes
  post '/computer_use/access_page', to: 'computer_use#access_page'
  post '/computer_use/screenshot', to: 'computer_use#screenshot'
  post '/computer_use/interact', to: 'computer_use#interact'
  post '/computer_use/extract_google_play_reviews', to: 'computer_use#extract_google_play_reviews'
  post '/computer_use/extract_page_data', to: 'computer_use#extract_page_data'
end
