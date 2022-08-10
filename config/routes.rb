# frozen_string_literal: true

Rails.application.routes.draw do
  resources :password_resets, only: %i[new create edit update]
  # ユーザーページのルーティング
  # トップ
  root to: "top#show"
  # static pages
  get "privacy", to: "static_pages#privacy"
  get "terms", to: "static_pages#terms"
  get "description", to: "static_pages#description"

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
    resources :likes, only: %i[create destroy]
    resources :comments, only: %i[index create show edit update destroy], shallow: true
  end

  resource :tex_compile, only: %i[create]
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

  # production 環境の AWS Cloud Front のためのURL設定
  direct :cdn_proxy do |model, options|
    cdn_options = {
      protocol: "https",
      port: 443,
      host: ENV["CDN_HOST"] # AWS Cloud Front のディストリビューションドメイン名
    }

    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id,
        model.filename,
        options.merge(cdn_options)
      )
    else
      signed_blob_id = model.blob.signed_id
      variation_key  = model.variation.key
      filename       = model.blob.filename

      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options.merge(cdn_options)
      )
    end
  end
end
