# frozen_string_literal: true

module CreateQuestion
  def create_question(year, univ_name, dept_name, question_number, subject_name = nil, unit_name = nil, tex_code = nil)
    visit new_admin_question_path
    # 出題年を2000に設定
    select year, from: "出題年"
    # 大学ラジオボタン「東京」をchoose
    within(".university-radio-buttons") { click_button }
    choose univ_name
    # 学部checkboxの「理系」チェックし、その問題番号を10に設定
    check dept_name
    select question_number, from: "問題番号"
    # 単元の「数と式・集合と論理」をチェック
    within(".subject#{subject_name}") { check unit_name } unless unit_name.nil?

    unless tex_code.nil?
      # 問題文texをコンパイル
      fill_in "texコード", with: tex_code
      click_button "コンパイルする"
      page.find("#compile-message", text: "コンパイルに成功しました。")
      # expect(page).to have_content "コンパイルに成功しました。"
    end
    click_button "問題を作成する"
  end
end

RSpec.configure do |config|
  config.include CreateQuestion
end
