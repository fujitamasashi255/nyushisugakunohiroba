# frozen_string_literal: true

class Unit < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Rails.root.join("config/masters")
  set_filename "unit"

  has_many :questions_units_mediators, dependent: :destroy

  # 科目の配列を取得する
  scope :subjects, -> { pluck(:subject).uniq }

  def questions
    Question.joins(:questions_units_mediators).where(questions_units_mediators: { unit_id: id }).distinct
  end
end
