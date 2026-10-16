Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "sessions#new"
  post "demo/:role", to: "sessions#create", as: :demo_session, constraints: { role: /agent|customer/ }
  delete "session", to: "sessions#destroy", as: :session
  resources :tickets, only: [:index, :new, :create, :show] do
    member do
      post :assign
      post :resolve
      post :reopen
      post :preview_reply
      post :reply
      post :internal_note
      post :customer_reply
    end
  end
end
