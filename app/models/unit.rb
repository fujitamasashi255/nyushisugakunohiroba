# frozen_string_literal: true

class Unit < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Rails.root.join("config/masters")
  set_filename "unit"

  has_many :questions_units_mediators, dependent: :destroy

  # 科目の配列を取得する
  scope :subjects, -> { pluck(:subject).uniq }

  def questions
    Question.find(questions_units_mediators.pluck(:question_id))
  end
end
