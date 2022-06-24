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
require "rails_helper"

RSpec.describe Question, type: :model do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

  describe "バリデーション" do
    it "出題年、区分、問題番号、問題文のある問題は登録できること" do
      question = build(:question, :has_a_department_with_question_number)
      expect(question).to be_valid
    end

    it "出題年のない問題は登録できないこと" do
      question = build(:question, :has_a_department_with_question_number, year: nil)
      expect(question).to be_invalid
      expect(question.errors[:year]).to eq ["を入力して下さい"]
    end

    it "区分がない問題は登録できないこと" do
      question = build(:question)
      expect(question).to be_invalid
      expect(question.errors[:base]).to eq ["区分を登録して下さい"]
    end

    it "問題番号のない問題は登録できないこと" do
      question = build(:question, :has_a_department_with_question_number, question_number: nil)
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
      department = create(:department)
      create(:question, :has_a_department_with_question_number, department:, question_number: 1, year: 2000)
      question_another = build(:question, :has_a_department_with_question_number, department:, question_number: 1, year: 2000)
      expect(question_another).to be_invalid
      expect(question_another.errors[:base]).to eq ["出題年、区分、問題番号の組が同じ問題が存在します。"]
    end

    it "問題文のない問題は登録できないこと" do
      question = build(:question, :has_a_department_with_question_number, image: nil)
      expect(question).to be_invalid
      expect(question.errors[:image]).to eq ["を作成して下さい"]
    end
  end

  describe "クラスメソッド" do
    before do
      @all_units = Unit.all.order(:id).to_a
      @first_unit = @all_units.first
      @second_unit = @all_units.second
      @third_unit = @all_units.third
      {
        1 => { year: 2002, university_id: 3, unitz: [@first_unit, @second_unit] }, # question1のunits
        2 => { year: 2001, university_id: 1, unitz: [@second_unit, @third_unit] }, # question2のunits
        3 => { year: 2003, university_id: 2, unitz: [@second_unit, @first_unit] }  # question3のunits
      }.each do |key, value|
        instance_variable_set("@question#{key}", create(:question, :has_univ_id_and_unitz, year: value[:year], university_id: value[:university_id], unitz: value[:unitz]))
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

    describe "by_tag_name_array(tag_name_array)" do
      before do
        @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
        @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
        @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
        create(:answer, question: @question_kyoto, user:, tag_names: "tag1")
        create(:answer, question: @question_nagoya, user:, tag_names: "tag2")
        create(:answer, question: @question_tokyo, user:, tag_names: "tag3")
      end

      it "指定したタグをもつ問題を取得できること" do
        questions = Question.all.by_tag_name_array(%w[tag1 tag2])
        expect(questions).to contain_exactly(@question_kyoto, @question_nagoya)
      end
    end

    describe "by_user(user)" do
      before do
        @user1 = create(:user, name: "test1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
        @user2 = create(:user, name: "test2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
        @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
        @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
        @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
        create(:answer, question: @question_kyoto, user: @user1)
        create(:answer, question: @question_nagoya, user: @user1)
        create(:answer, question: @question_nagoya, user: @user2)
        create(:answer, question: @question_tokyo, user: @user2)
      end

      it "指定したユーザーが解答を作成した問題を取得できること" do
        questions = Question.all.by_user(@user1)
        expect(questions).to contain_exactly(@question_kyoto, @question_nagoya)
      end
    end

    describe "by_answers(answers)" do
      before do
        user1 = create(:user, name: "test1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
        user2 = create(:user, name: "test2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
        @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
        @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
        @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
        @answer1 = create(:answer, question: @question_kyoto, user: user1)
        @answer2 = create(:answer, question: @question_nagoya, user: user1)
        @answer3 = create(:answer, question: @question_nagoya, user: user2)
        @answer4 = create(:answer, question: @question_tokyo, user: user2)
      end

      it "指定した解答の問題を取得できること" do
        questions = Question.all.by_answers([@answer1, @answer2, @answer3])
        expect(questions).to contain_exactly(@question_kyoto, @question_nagoya)
      end
    end
  end

  describe "インスタンスメソッド" do
    describe "unitとの関連" do
      before do
        @unit1, @unit2, @unit3 = Unit.all.to_a[0, 3]
        @unitz = [@unit1, @unit2, @unit3]
        @question = create(:question, :has_univ_id_and_unitz, unitz: @unitz)
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

      describe "answer_of_user(user)" do
        before do
          @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
          @answer = create(:answer, question: @question_kyoto, user:)
        end

        it "問題に対し、指定したユーザーの解答を取得できること" do
          answer = @question_kyoto.answer_of_user(user)
          expect(answer).to eq @answer
        end
      end

      describe "tags_belongs_to_same_unit_of_user(user)" do
        before do
          @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
          @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
          @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "図形と計量")
          @answer1 = create(:answer, question: @question_kyoto, user:, tag_names: "tag1")
          @answer2 = create(:answer, question: @question_nagoya, user:, tag_names: "tag2")
          @answer3 = create(:answer, question: @question_tokyo, user:, tag_names: "tag3")
        end

        it "問題に対し、それと同じ単元をもつ問題にユーザーがづけたタグを取得できること" do
          tags = @question_kyoto.tags_belongs_to_same_unit_of_user(user)
          expect(tags.map(&:name)).to contain_exactly("tag1", "tag3")
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
    end

    describe "departments_to_association" do
      let!(:question) { create(:question, :has_a_department_with_question_number) }

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
        question.departments_to_association(questions_departments_mediator_params)
        expect(Department.find(question.questions_departments_mediators.pluck(:department_id))).to contain_exactly(new_department1, new_department2)
      end
    end

    describe "university" do
      it "問題と関連するdepartmentsの属するuniversityが取得できること" do
        department = create(:department, university: create(:university, id: 1))
        question = create(:question, :has_a_department_with_question_number, department:)
        expect(question.university).to eq University.find(1)
      end
    end

    describe "画像の添付" do
      let!(:question) { create(:question, :has_a_department_with_question_number) }

      describe "attach_question_image" do
        before do
          create(:tex, :with_attachment, texable: question)
          question.attach_question_image
        end

        it "texのpdfがあるとき、pdfを画像にしたものを問題にattachできること" do
          expect(question.image.attached?).to be_truthy
        end

        it "texのpdfがないとき、問題にattachされていた画像が削除されること" do
          question.tex.pdf.purge
          question.attach_question_image
          expect(question.image.attached?).to be_falsy
        end
      end
    end
  end
end
