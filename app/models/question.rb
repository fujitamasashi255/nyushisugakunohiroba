# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question < ApplicationRecord
  validates :year, presence: true
  validate :departments_belong_to_same_university?
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

  def university
    # departmentsのdepartmentがbelongs_toしている大学は同じで、それを取得する
    departments[0].university if departments[0].present?
  end

  # tex.pdfをpngにして、余白を取り除いた画像を@question.imageにattachする
  # tex.pdf がなく、imageがattachされている場合はそのimageを削除する
  def attach_question_image
    if tex.pdf.present?
      image.attach(tex.pdf_to_img_blob.signed_id)
    elsif image.attached?
      image.purge
    end
  end

  private

  # questionのdepartmentが少なくとも1つはあること
  def department?
    errors.add(:base, "区分を登録してください") if department_ids.blank?
  end

  # questionのdepartmentsが属するuniversityが1つだけかチェック
  def departments_belong_to_same_university?
    errors.add(:base, "異なる大学に登録することはできません") if departments.map(&:university_id).uniq.count > 1
  end
end
