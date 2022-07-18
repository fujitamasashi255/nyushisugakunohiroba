# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id          :uuid             not null, primary key
#  ggb_base64  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_answers_on_question_id              (question_id)
#  index_answers_on_question_id_and_user_id  (question_id,user_id) UNIQUE
#  index_answers_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Answer, type: :model do
  before do
    @user = create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
    department = create(:department, name: "dept", university: create(:university, name: "univ"))
    @question = create(:question, :full_custom, year: 2020, department:, question_number: 5)
  end

  describe "バリデーション" do
    it "ユーザーは1つの問題に1つの解答しか作成できないこと" do
      create(:answer, question: @question, user: @user)
      another_answer = build(:answer, question: @question, user: @user)
      expect(another_answer).to be_invalid
      expect(another_answer.errors[:question_id]).to eq ["の解答は既に作成されています"]
    end

    it "ユーザーは解答にjpg、png、pdf以外のファイルをattachできないこと" do
      answer = build(:answer, :attached_text_file, question: @question, user: @user)
      expect(answer).to be_invalid
      expect(answer.errors[:files]).to eq ["の種類が正しくありません"]
    end

    it "ユーザーは解答にjpgファイルをattachできること" do
      answer = build(:answer, :attached_jpg_file, question: @question, user: @user)
      expect(answer).to be_valid
    end

    it "ユーザーは解答にpngファイルをattachできること" do
      answer = build(:answer, :attached_png_file, question: @question, user: @user)
      expect(answer).to be_valid
    end

    it "ユーザーは解答にpdfファイルをattachできること" do
      answer = build(:answer, :attached_pdf_file, question: @question, user: @user)
      expect(answer).to be_valid
    end

    it "ユーザーは解答に3MB以下のファイルしかattachできないこと" do
      answer = build(:answer, :attached_over_3MB_file, question: @question, user: @user)
      expect(answer).to be_invalid
      expect(answer.errors[:files]).to eq ["のサイズは3MB以下にして下さい"]
    end

    it "ユーザーは解答に3つ以下のファイルしかattachできないこと" do
      answer = build(:answer, :attached_4_files, question: @question, user: @user)
      expect(answer).to be_invalid
      expect(answer.errors[:files]).to eq ["は3つ以下にして下さい"]
    end
  end

  describe "メソッド" do
    let(:department_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
    let(:department_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
    let(:department_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

    before do
      @question_kyoto = create(:question, :full_custom, year: 2020, department: department_kyoto, question_number: 5, unit_names: %w[図形と計量])
      @question_nagoya = create(:question, :full_custom, year: 2010, department: department_nagoya, question_number: 7, unit_names: %w[図形と計量 三角関数])
      @question_tokyo = create(:question, :full_custom, year: 2000, department: department_tokyo, question_number: 10, unit_names: %w[数と式・集合と論理 図形と計量])
      @answer_kyoto = create(:answer, question: @question_kyoto, user: @user, tag_names: "tag1")
      @answer_nagoya = create(:answer, question: @question_nagoya, user: @user, tag_names: "tag2")
      @answer_tokyo = create(:answer, question: @question_tokyo, user: @user, tag_names: "tag3")
    end

    describe "by_university_ids(university_ids)" do
      it "大学名で解答を絞れること" do
        university_kyoto_id = department_kyoto.university.id
        university_nagoya_id = department_nagoya.university.id
        university_ids = [university_kyoto_id, university_nagoya_id]
        answers = Answer.all.by_university_ids(university_ids)
        expect(answers).to contain_exactly(@answer_kyoto, @answer_nagoya)
      end
    end

    describe "by_year(start_year, end_year)" do
      it "出題年で解答を絞れること" do
        answers = Answer.all.by_year(2010, 2020)
        expect(answers).to contain_exactly(@answer_kyoto, @answer_nagoya)
      end
    end

    describe "by_unit_ids(unit_ids)" do
      it "単元で解答を絞れること" do
        unit1 = Unit.find_by(name: "図形と計量")
        unit2 = Unit.find_by(name: "三角関数")
        answers = Answer.all.by_unit_ids([unit1.id, unit2.id])
        expect(answers).to contain_exactly(@answer_nagoya)
      end
    end

    describe "by_tag_name_array(tag_name_array)" do
      it "タグ名で解答を絞れること" do
        answers = Answer.all.by_tag_name_array(%w[tag1 tag2])
        expect(answers).to contain_exactly(@answer_kyoto, @answer_nagoya)
      end
    end

    describe "by_questions(questions)" do
      it "問題で解答を絞れること" do
        questions = [@question_kyoto, @question_nagoya]
        answers = Answer.all.by_questions(questions)
        expect(answers).to contain_exactly(@answer_kyoto, @answer_nagoya)
      end
    end

    describe "assign_files_position(file_blob_signed_id_to_position_hash)" do
      it "answer の files の position をセットできること" do
        answer = build(:answer, question: @question, user: @user)
        path1 = Rails.root.join("spec/files/test.pdf")
        path2 = Rails.root.join("spec/files/test.png")
        path3 = Rails.root.join("spec/files/test.jpg")
        # pathのblobを作成
        [path1, path2, path3].each.with_index(1) do |path, i|
          instance_variable_set("@blob#{i}", ActiveStorage::Blob.create_and_upload!(io: File.new(path), filename: File.basename(path)))
        end
        answer.files.attach([@blob1.signed_id, @blob2.signed_id, @blob3.signed_id])
        # blobのsigned_idを作成
        answer.files.each.with_index(1) do |file, i|
          instance_variable_set("@file#{i}", file)
          instance_variable_set("@signed_id#{i}", file.blob.signed_id)
        end
        expect(@file1.position.nil?).to be_truthy
        expect(@file2.position.nil?).to be_truthy
        expect(@file3.position.nil?).to be_truthy
        file_blob_signed_id_to_position_hash = { @signed_id1 => 2, @signed_id2 => 3, @signed_id3 => 1 }
        # メソッドを利用
        answer.assign_files_position(file_blob_signed_id_to_position_hash)
        expect(@file1.position).to eq 2
        expect(@file2.position).to eq 3
        expect(@file3.position).to eq 1
      end
    end

    describe "update_files_position(file_blob_signed_id_to_position_hash)" do
      it "answer の files の position をアップデートできること" do
        answer = build(:answer, question: @question, user: @user)
        path1 = Rails.root.join("spec/files/test.pdf")
        path2 = Rails.root.join("spec/files/test.png")
        path3 = Rails.root.join("spec/files/test.jpg")
        # pathのblobを作成
        [path1, path2, path3].each.with_index(1) do |path, i|
          instance_variable_set("@blob#{i}", ActiveStorage::Blob.create_and_upload!(io: File.new(path), filename: File.basename(path)))
        end
        answer.files.attach([@blob1.signed_id, @blob2.signed_id, @blob3.signed_id])
        # blobのsigned_idを作成
        answer.files.each.with_index(1) do |file, i|
          instance_variable_set("@file#{i}", file)
          instance_variable_set("@signed_id#{i}", file.blob.signed_id)
        end
        expect(@file1.position.nil?).to be_truthy
        expect(@file2.position.nil?).to be_truthy
        expect(@file3.position.nil?).to be_truthy
        file_blob_signed_id_to_position_hash = { @signed_id1 => 2, @signed_id2 => 3, @signed_id3 => 1 }
        # メソッドを利用
        answer.update_files_position(file_blob_signed_id_to_position_hash)
        expect(@file1.position).to eq 2
        expect(@file2.position).to eq 3
        expect(@file3.position).to eq 1
      end
    end

    describe "save_transaction(positions_array)" do
      before do
        @answer = build(:answer, question: @question, user: @user)
      end

      it "filesのポジションが適切な%w[2 3 1]のとき、answerを保存できること" do
        positions_array = %w[2 3 1]
        @answer.save_transaction(positions_array)
        expect(Answer.exists?(@answer.id)).to be_truthy
      end

      it "filesのポジションが適切な%w[2 1]のとき、answerを保存できること" do
        positions_array = %w[2 1]
        @answer.save_transaction(positions_array)
        expect(Answer.exists?(@answer.id)).to be_truthy
      end

      it "filesのポジションが適切な[]のとき、answerを保存できること" do
        positions_array = []
        @answer.save_transaction(positions_array)
        expect(Answer.exists?(@answer.id)).to be_truthy
      end

      it "filesのポジションが適切でない%w[2 3]とき、answerを保存できないこと" do
        positions_array = %w[2 3]
        @answer.save_transaction(positions_array)
        expect(Answer.exists?(@answer.id)).to be_falsy
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end

      it "filesのポジションが適切でない%w[1 3]とき、answerを保存できないこと" do
        positions_array = %w[1 3]
        @answer.save_transaction(positions_array)
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end

      it "filesのポジションが適切でない%w[1 2 3 4]とき、answerを保存できないこと" do
        positions_array = %w[1 2 3 4]
        @answer.save_transaction(positions_array)
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end
    end

    describe "update_transaction(params, positions_array)" do
      before do
        @answer = create(:answer, question: @question, user: @user, point: "")
        @params = { point: "ポイント" }
      end

      it "filesのポジションが適切な%w[2 3 1]のとき、answerをアップデートできること" do
        positions_array = %w[2 3 1]
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq "ポイント"
      end

      it "filesのポジションが適切な%w[2 1]のとき、answerをアップデートできること" do
        positions_array = %w[2 1]
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq "ポイント"
      end

      it "filesのポジションが適切な[]のとき、answerをアップデートできること" do
        positions_array = []
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq "ポイント"
      end

      it "filesのポジションが適切でない%w[2 3]とき、answerをアップデートできないこと" do
        positions_array = %w[2 3]
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq ""
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end

      it "filesのポジションが適切でない%w[1 3]とき、answerをアップデートできないこと" do
        positions_array = %w[1 3]
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq ""
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end

      it "filesのポジションが適切でない%w[1 2 3 4]とき、answerをアップデートできないこと" do
        positions_array = %w[1 2 3 4]
        @answer.update_transaction(@params, positions_array)
        expect(@answer.point.body.to_plain_text).to eq ""
        expect(@answer.errors.messages[:files_position]).to eq ["が適切ではありません"]
      end
    end
  end
end
