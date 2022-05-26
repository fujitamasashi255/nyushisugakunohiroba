# frozen_string_literal: true

module CreateQuestion
  def create_question(year, univ_name, dept_name, question_number, subject_name = nil, unit_name = nil, tex_code = nil)
    visit new_admin_question_path
    select year, from: "出題年"
    within(".university-radio-buttons") { click_button }
    choose univ_name
    within(".university-radio-buttons") { click_button }
    check dept_name
    select question_number, from: "問題番号"
    within(".subject#{subject_name}") { check unit_name } unless unit_name.nil?

    unless tex_code.nil?
      # 問題文texをコンパイル
      fill_in "texコード", with: tex_code
      click_button "コンパイルする"
      expect(page).to have_selector("#compile-message", text: "コンパイルに成功しました。")
      expect(page).to have_selector("embed[type='application/pdf']")
    end
    click_button "問題を作成する"
  end
end

RSpec.configure do |config|
  config.include CreateQuestion
end
