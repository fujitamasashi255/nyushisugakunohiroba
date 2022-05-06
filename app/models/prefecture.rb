# frozen_string_literal: true

class Prefecture < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Rails.root.join("config/masters")
  set_filename "prefecture"

  has_many :universities, dependent: :destroy

  # 科目の配列を取得する
  scope :subjects, -> { pluck(:subject).uniq }

  def questions
    Question.find(questions_units_mediators.map(&:question_id))
  end
end
