# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                  :uuid             not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  crypted_password                    :string
#  email                               :string           not null
#  name                                :string           not null
#  remember_me_token                   :string
#  remember_me_token_expires_at        :datetime
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  role                                :integer          default("general"), not null
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_remember_me_token     (remember_me_token)
#  index_users_on_reset_password_token  (reset_password_token)
#
require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "ユーザーが作成できること" do
      user = build(:user, name: "test", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd")
      expect(user).to be_valid
    end

    it "名前のないユーザーは作成できないこと" do
      user = build(:user, name: "")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("お名前 を入力して下さい")
    end

    it "名前が10文字より長いとき、ユーザーは作成できないこと" do
      user = build(:user, name: "hogehogehoge")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("お名前 は10文字以下で入力して下さい")
    end

    it "メールアドレスのないとき、ユーザーは作成できないこと" do
      user = build(:user, email: "")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("メールアドレス は不正な値です", "メールアドレス を入力して下さい")
    end

    it "メールアドレスが不正な値であるとき、ユーザーは作成できないこと" do
      user = build(:user, email: "hogehoge")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("メールアドレス は不正な値です")
    end

    it "既に登録されているメールアドレスのとき、ユーザー作成できないこと" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("メールアドレス は既に存在します")
    end

    it "パスワードが入力されていないとき、ユーザーは作成できないこと" do
      user = build(:user, password: nil, password_confirmation: "1234abcd")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード は8文字以上で入力して下さい", "パスワード は不正な値です", "パスワード確認 とパスワードの入力が一致しません")
    end

    it "パスワードが8文字より短いとき、ユーザーは作成できないこと" do
      user = build(:user, password: "1234abc", password_confirmation: "1234abc")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード は8文字以上で入力して下さい")
    end

    it "パスワードに英字のないとき、ユーザーは作成できないこと" do
      user = build(:user, password: "12345678", password_confirmation: "12345678")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード は不正な値です")
    end

    it "パスワードに数字のないとき、ユーザーは作成できないこと" do
      user = build(:user, password: "ABCDabcd", password_confirmation: "ABCDabcd")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード は不正な値です")
    end

    it "パスワード確認とパスワードが一致しないとき、ユーザーは作成できないこと" do
      user = build(:user, password: "1234abcd", password_confirmation: "abcd1234")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード確認 とパスワードの入力が一致しません")
    end

    it "1MBより大きい画像をプロフィール画像に登録できないこと" do
      user = build(:user, :attached_over_1MB_file)
      expect(user).to be_invalid
      expect(user.errors[:avatar]).to eq ["サイズは1MB以下にして下さい"]
    end
  end

  describe "コールバック" do
    it "新規作成時にavatarがattachされること" do
      user = create(:user)
      expect(user.avatar.attached?).to be_truthy
    end
  end

  describe "インスタンスメソッド" do
    let(:user) { create(:user, name: "TEST", email: "user@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
    let(:another_user) { create(:user, name: "ANOTHER", email: "another@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
    let(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
    let(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
    let(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

    before do
      # 京都大学、名古屋大学、東京大学の問題
      @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit_names: %w[図形と計量])
      @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit_names: %w[三角関数])
      @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit_names: %w[数と式・集合と論理])
      # 京都大学の解答：2個、名古屋大学の解答：1個、東京大学の解答：0個
      @answer_kyoto = create(:answer, question: @question_kyoto, user:)
      @answer_nagoya = create(:answer, question: @question_nagoya, user:)
      @answer_tokyo = create(:answer, question: @question_tokyo, user: another_user)
    end

    describe "question_id_to_answer_id_hash" do
      it "ユーザーの作成した解答のidをvalue、その問題をkeyとするハッシュが取得できること" do
        expect_hash = { @question_kyoto.id => @answer_kyoto.id, @question_nagoya.id => @answer_nagoya.id }
        expect(user.question_id_to_answer_id_hash).to eq expect_hash
      end
    end

    describe "own_answer?(answer)" do
      it "作成した解答に対して、trueを返すこと" do
        expect(user.own_answer?(@answer_kyoto)).to be_truthy
      end

      it "作成していない解答に対して、falseを返すこと" do
        expect(user.own_answer?(@answer_tokyo)).to be_falsy
      end
    end
  end
end
