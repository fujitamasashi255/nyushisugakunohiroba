# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    root to: "dashboards#index"
    resources :universities
  end
end
