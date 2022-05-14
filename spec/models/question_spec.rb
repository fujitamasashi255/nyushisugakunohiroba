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
require "rails_helper"

RSpec.describe Question, type: :model do
  describe "バリデーション" do
    it "出題年、区分、問題番号のある問題は登録できること" do
      question = build(:question, :has_departments_with_question_number)
      expect(question).to be_valid
    end

    it "出題年のない問題は登録できないこと" do
      question = build(:question, :has_departments_with_question_number, year: nil)
      expect(question).to be_invalid
      expect(question.errors[:year]).to eq ["を入力して下さい"]
    end

    it "区分がない問題は登録できないこと" do
      question = build(:question, :has_departments_with_question_number, department_counts: 0)
      expect(question).to be_invalid
      expect(question.errors[:base]).to eq ["区分を登録して下さい"]
    end

    it "問題番号のない問題は登録できないこと" do
      question = build(:question, :has_no_question_number)
      expect(question).to be_invalid
      expect(question.questions_departments_mediators[0].errors[:question_number]).to eq ["を入力して下さい"]
    end

    it "異なる大学の学部には登録できないこと" do
      question = build(:question, :has_different_university)
      expect(question).to be_invalid
      expect(question.errors[:base]).to eq ["異なる大学に登録することはできません"]
    end

    it "同一学部に同じ問題を2回以上登録できないこと" do
      question = build(:question, :has_same_departments)
      expect(question).to be_invalid
      expect(question.errors[:base]).to eq ["同一学部に同じ問題を2回以上登録できません"]
    end

    it "出題年、区分、問題番号が同じ問題は作成できないこと" do
      question = create(:question, :has_departments_with_question_number, department_counts: 1)
      mediator = question.questions_departments_mediators[0]
      # questionと出題年、区分、問題番号が同じ問題question_anotherをbuild
      question_another = build(:question, year: question.year)
      question_another.questions_departments_mediators << build(:questions_departments_mediator, department: mediator.department, question_number: mediator.question_number)
      expect(question_another).to be_invalid
      expect(question_another.errors[:base]).to eq ["出題年、区分、問題番号の組が同じ問題が存在します。"]
    end
  end

  describe "クラスメソッド" do
    before do
      @all_units = Unit.all.order(:id).to_a
      @first_unit = @all_units.first
      @second_unit = @all_units.second
      @third_unit = @all_units.third
      {
        1 => { year: 2002, university_id: 3, unitz: [@first_unit, @second_unit] },
        2 => { year: 2001, university_id: 1, unitz: [@second_unit, @third_unit] },
        3 => { year: 2003, university_id: 2, unitz: [@second_unit, @first_unit] }
      }.each do |key, value|
        instance_variable_set("@question#{key}", create(:question, :has_univ_id_and_unitz, year: value[:year], university_id: value[:university_id], unitz: value[:unitz]))
      end
    end

    describe "default_scope" do
      it "問題がyearの新しい順であること" do
        expect(Question.all.first).to eq @question3
        expect(Question.all.second).to eq @question1
        expect(Question.all.third).to eq @question2
      end
    end

    describe "by_university_ids" do
      it "university_idが1または2である問題が取得できること" do
        expect(Question.all.by_university_ids([1, 2])).to contain_exactly(@question2, @question3)
      end
    end

    describe "by_year" do
      it "yearが2001または2002の問題が取得できること" do
        expect(Question.all.by_year(2001, 2002)).to contain_exactly(@question1, @question2)
      end
    end

    describe "by_unit_ids" do
      it "idが最も小さいunitを持つ問題が取得できること" do
        expect(Question.all.by_unit_ids([@first_unit.id])).to contain_exactly(@question1, @question3)
      end

      it "idが最も小さいunitと2番目に小さいunitの少なくとも一方を含む問題が取得できること" do
        expect(Question.all.by_unit_ids([@first_unit.id, @second_unit.id])).to contain_exactly(@question1, @question2, @question3)
      end
    end
  end

  describe "インスタンスメソッド" do
    before do
      @unit1, @unit2, @unit3 = Unit.all.to_a[0, 3]
      @unitz = [@unit1, @unit2, @unit3]
      @question = create(:question, :has_univ_id_and_unitz, university_id: 1, unitz: @unitz)
    end

    describe "units" do
      it "問題のunitが取得できること" do
        expect(@question.units).to contain_exactly(@unit1, @unit2, @unit3)
      end
    end

    describe "unit_ids" do
      it "問題と関連するunitのidの配列が取得できること" do
        expect(@question.unit_ids).to contain_exactly(@unit1.id, @unit2.id, @unit3.id)
      end
    end

    describe "units_to_association" do
      it "問題と関連するunitをnew_unitsに変更する" do
        new_units = Unit.all.to_a[3, 3]
        new_unit_ids = new_units.map(&:id)
        @question.units_to_association(new_unit_ids)
        expect(@question.units).to contain_exactly(new_units[0], new_units[1], new_units[2])
      end
    end

    describe "departments_to_association" do
      it "問題と関連するdepartmentがnew_department1とnew_department2になること" do
        new_university = create(:university)
        new_department1 = create(:department, university: new_university)
        new_department2 = create(:department, university: new_university)
        questions_departments_mediator_params = {
          questions_departments_mediator: {
            new_department1.id => { question_number: 1 },
            new_department2.id => { question_number: 2 }
          }
        }
        @question.departments_to_association(questions_departments_mediator_params)
        expect(Department.find(@question.questions_departments_mediators.map(&:department_id))).to contain_exactly(new_department1, new_department2)
      end
    end

    describe "university" do
      it "問題と関連するdepartmentsの属するuniversityが取得できること" do
        expect(@question.university).to eq University.find(1)
      end
    end

    describe "attach_question_image" do
      xit "問題に問題文の画像をattachできること"
    end
  end
end
