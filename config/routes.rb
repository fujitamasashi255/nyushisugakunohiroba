# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    root to: "dashboards#index"
    resources :universities do
      resources :department_check_boxes, only: %i[index]
    end
    resources :questions
    resource :questions_search_form, only: %i[show]
    resources :questions_sorts, only: %i[show], param: :sort_type
  end

  resource :compile, only: %i[create]
end
