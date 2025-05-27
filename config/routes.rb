Rails.application.routes.draw do
  root 'chats#index'

  resources :chats do
    resources :messages, only: [:create]
  end
end
