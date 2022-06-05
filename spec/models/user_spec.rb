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

    it "名前が1文字以上10文字以下のユーザーを作成できること" do
      user = build(:user, name: "hoge")
      expect(user).to be_valid
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

    it "パスワードが8英子文字、数字をいずれも含み、8文字以上のとき、ユーザーを作成できること" do
      user = build(:user, password: "1234abcd", password_confirmation: "1234abcd")
      expect(user).to be_valid
    end

    it "パスワード確認とパスワードが一致しないとき、ユーザーは作成できないこと" do
      user = build(:user, password: "1234abcd", password_confirmation: "abcd1234")
      expect(user).to be_invalid
      expect(user.errors.full_messages).to contain_exactly("パスワード確認 とパスワードの入力が一致しません")
    end
  end

  describe "コールバック" do
    fit "新規作成時にavatarがattachされること" do
      user = create(:user)
      expect(user.avatar.attached?).to be_truthy
    end
  end
end
