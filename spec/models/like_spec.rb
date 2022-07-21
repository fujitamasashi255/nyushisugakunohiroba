# frozen_string_literal: true

# == Schema Information
#
# Table name: likes
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  answer_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_likes_on_answer_id              (answer_id)
#  index_likes_on_user_id                (user_id)
#  index_likes_on_user_id_and_answer_id  (user_id,answer_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Like, type: :model do
  describe "バリデーション" do
    before do
      @user = create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      department = create(:department, name: "dept", university: create(:university, name: "univ"))
      question = create(:question, :full_custom, year: 2020, department:, question_number: 5)
      @answer = create(:answer, question:, user: @user)
    end

    it "ユーザーは同じ問題に2回以上いいねできないこと" do
      create(:like, answer: @answer, user: @user)
      second_like = build(:like, answer: @answer, user: @user)
      expect(second_like).to be_invalid
      expect(second_like.errors[:answer_id]).to eq ["は既にいいねされています"]
    end
  end
end
