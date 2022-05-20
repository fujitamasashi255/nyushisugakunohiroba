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
  validate :questions_departments_mediators?
  validate :year_dept_number_set_unique?
  validate :different_departments?

  has_many :questions_departments_mediators, dependent: :destroy
  has_many :departments, through: :questions_departments_mediators
  has_many :questions_units_mediators, dependent: :destroy
  has_one :tex, dependent: :destroy, as: :texable
  has_one_attached :image
  accepts_nested_attributes_for :tex, reject_if: :all_blank

  default_scope { order(year: :desc) }
  scope :by_university_ids, ->(university_ids) { joins(departments: :university).where(universities: { id: university_ids }).select("questions.*").distinct }
  scope :by_year, ->(start_year, end_year) { where(year: start_year..end_year) }
  scope :by_unit_ids, ->(unit_ids) { joins(:questions_units_mediators).where(questions_units_mediators: { unit_id: unit_ids }).select("questions.*").distinct }

  def units
    Unit.find(questions_units_mediators.map(&:unit_id))
  end

  def unit_ids
    units.pluck(:id)
  end

  def units_to_association(unit_idz)
    questions_units_mediators.clear
    unit_idz.each do |unit_id|
      questions_units_mediators.new(unit_id:)
    end
  end

  # questions_departments_mediator_params は { questions_departments_mediator: { dept_id: { question_number: hoge } }, ・・・ } の形のハッシュ
  def departments_to_association(questions_departments_mediator_params)
    # DBの question と関連するQuestionsDepartmentsMediatorレコードを削除する
    departments.destroy_all if questions_departments_mediators.exists?

    return if questions_departments_mediator_params.blank?

    # paramsから@questionと関連するQuestionsDepartmentsMediatorレコードを作成
    questions_departments_mediator_params[:questions_departments_mediator].each do |key, value|
      questions_departments_mediators.new(department_id: key, question_number: value[:question_number].to_i)
    end
  end

  def university
    # departmentsの要素がbelongs_toしているuniversityは同じなので、それを取得する。
    departments[0].university if departments.present?
  end

  # tex.pdfをpngにして、余白を取り除いた画像を@question.imageにattachする
  # tex.pdf がなく、imageがattachされている場合はそのimageを削除する
  def attach_question_image
    if tex.pdf.attached?
      image.attach(tex.pdf_to_img_blob.signed_id)
    elsif image.attached?
      image.purge
    end
  end

  private

  # questionのdepartmentが少なくとも1つはあること
  def questions_departments_mediators?
    errors.add(:base, :questions_departments_mediators?) if questions_departments_mediators.blank?
  end

  # questionのdepartmentsが属するuniversityが1つだけかチェック
  def departments_belong_to_same_university?
    depts = Department.find(questions_departments_mediators.map(&:department_id))
    errors.add(:base, :departments_belong_to_same_university?) if depts.map(&:university_id).uniq.size > 1
  end

  # 同じ学部に2回以上登録できないことをチェック
  def different_departments?
    dept_ids = questions_departments_mediators.map(&:department_id)
    errors.add(:base, :has_different_departments?) if dept_ids.uniq.size < dept_ids.size
  end

  # 出題年、区分、問題番号の組は一意
  def year_dept_number_set_unique?
    if Question.joins(questions_departments_mediators: :department).where(
      year:,
      questions_departments_mediators: { question_number: questions_departments_mediators.map(&:question_number) },
      department: { id: questions_departments_mediators.map { |medi| medi.department.id } }
    ).count.positive?
      errors.add(:base, :year_dept_number_set_unique?)
    end
  end
end
