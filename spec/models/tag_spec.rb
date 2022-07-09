# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id             :bigint           not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "メソッド" do
    let(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
    let(:department_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
    let(:department_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
    let(:department_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

    before do
      @question_kyoto = create(:question, :full_custom, year: 2020, department: department_kyoto, question_number: 5, unit: "図形と計量")
      @question_nagoya = create(:question, :full_custom, year: 2010, department: department_nagoya, question_number: 7, unit: "三角関数")
      @question_tokyo = create(:question, :full_custom, year: 2000, department: department_tokyo, question_number: 10, unit: "数と式・集合と論理")
      create(:answer, question: @question_kyoto, user:, tag_names: "tag1")
      create(:answer, question: @question_nagoya, user:, tag_names: "tag2")
      create(:answer, question: @question_tokyo, user:, tag_names: "tag3")
    end

    describe "by_questions(questions)" do
      it "問題でタグを絞れること" do
        questions = [@question_kyoto, @question_nagoya]
        tags = Tag.all.by_questions(questions)
        expect(tags.map(&:name)).to contain_exactly("tag1", "tag2")
      end
    end
  end
end
