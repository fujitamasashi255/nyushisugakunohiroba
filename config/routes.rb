# frozen_string_literal: true

Rails.application.routes.draw do
  resources :password_resets, only: %i[new create edit update]
  # ユーザーページのルーティング
  root to: "static_pages#top"
  resources :questions, only: %i[index show] do
    resources :answers, only: %i[new create show edit update destroy], shallow: true
    # 問題検索、並び替え
    get :search, on: :collection
  end

  resources :users, only: %i[new create show edit update destroy] do
    resources :answers, only: %i[index] do
      # 解答検索、並び替え
      get :search, on: :collection
    end
  end

  resources :questions_tags, only: %i[index]
  resources :answers_tags, only: %i[index]

  resources :answers, only: [] do
    resource :files, only: %i[destroy]
  end

  resource :pdfs, only: %i[create]
  resources :texes, only: %i[destroy]

  get "login" => "user_sessions#new", :as => :login
  post "login" => "user_sessions#create"
  delete "logout" => "user_sessions#destroy", :as => :logout

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # 管理ページのルーティング
  namespace :admin do
    root to: "dashboards#index"
    resources :universities do
      resources :department_check_boxes, only: %i[index]
    end
    resources :questions do
      # 問題検索、並び替え
      get :search, on: :collection
    end
  end
end
