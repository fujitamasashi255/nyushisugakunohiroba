# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
#  category      :integer          default("national_or_public"), not null
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
      university = build(:university, name: "")
      expect(university).to be_invalid
      expect(university.errors[:name]).to eq ["を入力して下さい"]
    end

    it "名前のある大学は作成できること" do
      university = build(:university, name: "test")
      expect(university).to be_valid
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

    it "都道府県を登録していない大学は作成できないこと" do
      university = build(:university, :has_no_prefecture)
      expect(university).to be_invalid
      expect(university.errors[:prefecture]).to eq ["を指定して下さい"]
    end

    it "カテゴリーを登録していない大学は作成できないこと" do
      university = build(:university, :without_category)
      expect(university).to be_invalid
      expect(university.errors[:category]).to eq ["を指定して下さい"]
    end

    it "同名の区分を持つ大学は作成できないこと" do
      university = build(:university, :has_same_name_departments)
      expect(university).to be_invalid
      expect(university.errors[:base]).to eq ["同じ名前の区分を登録することはできません"]
    end
  end
end
