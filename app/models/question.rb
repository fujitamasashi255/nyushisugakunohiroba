# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :uuid             not null, primary key
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question < ApplicationRecord
  has_many :questions_departments_mediators, dependent: :destroy
  has_many :departments, through: :questions_departments_mediators
  has_many :questions_units_mediators, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :answered_users, through: :answers, source: :user
  has_one :tex, dependent: :destroy, as: :texable
  has_one_attached :image
  accepts_nested_attributes_for :tex, reject_if: :all_blank

  delegate :name, to: :university, prefix: true, allow_nil: true

  validates :year, presence: true
  validate :departments_belong_to_same_university?
  validate :questions_departments_mediators?
  validate :different_departments?
  validates :image, attached: true

  scope :by_university_ids, ->(university_ids) { joins(departments: :university).where(universities: { id: university_ids }).distinct }
  scope :by_year, ->(start_year, end_year) { where(year: start_year..end_year) }
  scope :by_unit_ids, ->(unit_ids) { joins(:questions_units_mediators).where(questions_units_mediators: { unit_id: unit_ids }).distinct }
  scope :by_user, ->(user) { joins(:answers).where(answers: { user_id: user.id }).distinct }
  scope :by_answers, ->(answers) { joins(:answers).where(answers: { id: answers.map(&:id) }).distinct }
  scope :by_tag_name_array, lambda { |tag_name_array|
    left_joins(:answers)\
      .joins("INNER JOIN taggings ON answers.id = taggings.taggable_id")\
      .joins("INNER JOIN tags ON tags.id = taggings.tag_id")\
      .where(tags: { name: tag_name_array })\
      .distinct
  }

  def units
    Unit.find(questions_units_mediators.pluck(:unit_id))
  end

  def unit_ids
    units.pluck(:id)
  end

  # questionの解答のうち、userのものを返す
  def answer_of_user(user)
    answers.find_by(user_id: user.id)
  end

  # 同じ単元を持つ問題に対してユーザーがつけたタグを返す
  def tags_belongs_to_same_unit_of_user(user)
    Tag\
      .joins(:taggings)\
      .joins("INNER JOIN answers ON answers.id = taggings.taggable_id")\
      .joins("INNER JOIN questions ON answers.question_id = questions.id")\
      .joins("INNER JOIN questions_units_mediators ON questions_units_mediators.question_id = questions.id")\
      .where(questions_units_mediators: { unit_id: unit_ids })\
      .where(answers: { user_id: user.id })\
      .distinct
  end

  # unit_idzのunitをquestionの関連に入れる
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
end
