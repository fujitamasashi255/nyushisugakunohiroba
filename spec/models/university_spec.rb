# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  prefecture_id :bigint
#
# Indexes
#
#  index_universities_on_name  (name) UNIQUE
#
require "rails_helper"

RSpec.describe University, type: :model do
  describe "バリデーション" do
    it "名前のない大学は作成できないこと" do
      university_without_name = build(:university, name: "")
      expect(university_without_name).to be_invalid
      expect(university_without_name.errors[:name]).to eq ["を入力して下さい"]
    end

    it "名前のある大学は作成できること" do
      university_with_name = build(:university, name: "test")
      expect(university_with_name).to be_valid
    end

    it "同名の大学を作成できないこと" do
      university = create(:university, name: "test")
      university_with_same_name = build(:university, name: university.name)
      expect(university_with_same_name).to be_invalid
      expect(university_with_same_name.errors[:name]).to eq ["は既に存在します"]
    end

    it "異なる名前の大学を作成できること" do
      create(:university, name: "test")
      university_with_different_name = build(:university, name: "TEST")
      expect(university_with_different_name).to be_valid
    end
  end
end
