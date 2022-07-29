# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
  let!(:department) { create(:department, name: "DEPT", university: create(:university, name: "UNIV", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:question) { create(:question, :full_custom, year: 2000, department:, question_number: 5, unit_names: %w[三角関数]) }
  let!(:answer) { create(:answer, question:, user:) }

  describe "バリデーション" do
    it "0文字のコメントは作成できないこと" do
      comment = build(:comment, commentable: answer, user:, body_text: "")
      expect(comment).to be_invalid
      expect(comment.errors[:body]).to eq ["を入力してください"]
    end

    it "1000文字のコメントは作成できること" do
      body_text = +""
      50.times { body_text << "abcdefghijklmnopqrst" } # 20文字
      comment = build(:comment, commentable: answer, user:, body_text:)
      expect(comment).to be_valid
    end

    it "1001文字のコメントは作成できないこと" do
      body_text = +"a"
      50.times { body_text << "abcdefghijklmnopqrst" } # 20文字
      comment = build(:comment, commentable: answer, user:, body_text:)
      expect(comment).to be_invalid
      expect(comment.errors[:body]).to eq ["は1000文字以下で入力してください"]
    end
  end
end
