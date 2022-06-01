# frozen_string_literal: true

Rails.application.routes.draw do
  resources :password_resets, only: [:new, :create, :edit, :update]
  # ユーザーページのルーティング
  root to: "static_pages#top"
  resources :questions, only: %i[index show]
  resources :users
  get "login" => "user_sessions#new", :as => :login
  post "login" => "user_sessions#create"
  delete "logout" => "user_sessions#destroy", :as => :logout

  resource :questions_search_form, only: %i[show]
  resources :questions_sorts, only: %i[show], param: :sort_type

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # 管理ページのルーティング
  namespace :admin do
    root to: "dashboards#index"
    resources :universities do
      resources :department_check_boxes, only: %i[index]
    end
    resources :questions
    resource :questions_search_form, controller: "/questions_search_forms", only: %i[show]
    resources :questions_sorts, controller: "/questions_sorts", only: %i[show], param: :sort_type
  end

  resource :compile, only: %i[create]
end
