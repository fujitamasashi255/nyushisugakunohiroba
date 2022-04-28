# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  number     :integer          not null
#  set_year   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question < ApplicationRecord
  validates :number, presence: true
  validates :set_year, presence: true
  validate :departments_belong_to_same_university?
  validate :unit?
  validate :department?

  has_many :questions_departments_mediators, dependent: :destroy
  has_many :departments, through: :questions_departments_mediators
  has_many :questions_units_mediators, dependent: :destroy
  has_one :tex, dependent: :destroy, as: :texable
  has_one_attached :image
  accepts_nested_attributes_for :tex, reject_if: :all_blank

  def units
    Unit.find(questions_units_mediators.map(&:unit_id))
  end

  def unit_ids
    units.pluck(:id)
  end

  def units_to_association(unitz)
    questions_units_mediators.clear
    questions_units_mediators << unitz.map do |u|
      QuestionsUnitsMediator.new(unit_id: u.id)
    end
  end

  private

  # questionのdepartmentが少なくとも1つはあること
  def department?
    errors.add(:base, "区分を登録してください") if department_ids.blank?
  end

  # questionのunitが少なくとも1つはあること
  def unit?
    errors.add(:base, "単元を登録してください") if unit_ids.blank?
  end

  # questionのdepartmentsが属するuniversityが1つだけかチェック
  def departments_belong_to_same_university?
    errors.add(:base, "異なる大学に登録することはできません") if departments.map(&:university_id).uniq.count > 1
  end
end
