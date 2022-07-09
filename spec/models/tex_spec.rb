# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id                 :uuid             not null, primary key
#  code               :text
#  compile_result_url :string           default(""), not null
#  texable_type       :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  texable_id         :uuid             not null
#
# Indexes
#
#  index_texes_on_texable  (texable_type,texable_id)
#
require "rails_helper"

RSpec.describe Tex, type: :model do
  let(:question) { create(:question, :has_a_department_with_question_number) }

  describe "バリデーション" do
    it "関連するtexableがnilのとき作成できないこと" do
      tex = build(:tex, texable: nil)
      expect(tex).to be_invalid
      expect(tex.errors[:texable]).to eq ["を指定して下さい"]
    end

    it "関連するtexableがquestionレコードのとき作成できること" do
      tex = build(:tex, texable: question)
      expect(tex).to be_valid
    end
  end

  describe "インスタンスメソッド" do
    let!(:attached_tex) { create(:tex, :with_attachment, compile_result_url: "http://localhost:3000/#{Settings.dir.compile_result}/test_new.pdf", texable: question) }

    describe "attach_pdf" do
      context "compile_result_urlが空でなく、そのurlにpdfがあるとき" do
        before do
          FileUtils.cp Rails.root.join("spec/files/test.pdf"), Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf")
        end

        after(:each) do
          path = Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf")
          File.delete(path) if File.file?(path) && File.exist?(path)
        end

        it "そのpdfがattachされること" do
          expect(attached_tex.pdf.blob.filename).to eq "test.pdf"
          attached_tex.attach_pdf
          expect(attached_tex.pdf.attached?).to be_truthy
          expect(attached_tex.pdf.blob.filename).to eq "test_new.pdf"
        end
      end

      context "compile_result_urlが空でなく、そのurlにpdfがないとき" do
        it "attachされているpdfが変わらないこと" do
          expect(attached_tex.pdf.blob.filename).to eq "test.pdf"
          attached_tex.attach_pdf
          expect(attached_tex.pdf.attached?).to be_truthy
          expect(attached_tex.pdf.blob.filename).to eq "test.pdf"
        end
      end

      context "compile_result_urlが空文字のとき" do
        context "texableがAnswerの場合" do
          before do
            user = create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
            answer = create(:answer, question:, user:)
            @attached_tex_of_answer = create(:tex, :with_attachment, compile_result_url: "", texable: answer)
            @not_attached_tex_of_answer = create(:tex, :with_no_attachment, compile_result_url: "", texable: answer)
          end

          it "pdfがattachされていれば、そのpdfが削除されること" do
            @attached_tex_of_answer.attach_pdf
            expect(@attached_tex_of_answer.pdf.attached?).to be_falsy
          end

          it "pdfがattachされていなければ、pdfがattachされない状態のままのこと" do
            @not_attached_tex_of_answer.attach_pdf
            expect(@not_attached_tex_of_answer.pdf.attached?).to be_falsy
          end
        end

        context "texableがQuestionの場合" do
          let(:attached_tex_of_question) { create(:tex, :with_attachment, compile_result_url: "", texable: question) }

          it "attachされているpdfが変わらないこと" do
            expect(attached_tex_of_question.pdf.blob.filename).to eq "test.pdf"
            attached_tex_of_question.attach_pdf
            expect(attached_tex_of_question.pdf.blob.filename).to eq "test.pdf"
          end
        end
      end
    end

    describe "restore" do
      context "public/compile_result/ にコンパイルしたファイルがない時" do
        it "texオブジェクトのcompile_result_urlが空文字に、codeがデフォルト値になり、pdfが削除されること" do
          attached_tex.restore
          expect(attached_tex.compile_result_url).to eq ""
          expect(attached_tex.pdf.attached?).to be_falsy
          expect(attached_tex.code).to eq Settings.tex_default_code
        end
      end

      context "public/compile_result/ にコンパイルしたファイルがある時" do
        require "fileutils"

        before do
          # public/compile_resultにtest_new.pdfを作成
          FileUtils.cp Rails.root.join("spec/files/test.pdf"), Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf")
        end

        after(:each) do
          path = Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf")
          File.delete(path) if File.file?(path) && File.exist?(path)
        end

        it "texオブジェクトのcompile_result_urlが空文字に、codeがデフォルト値になり、pdfが削除され、public/compile_resultのpdfが削除されること" do
          attached_tex.restore
          expect(attached_tex.compile_result_url).to eq ""
          expect(attached_tex.pdf.attached?).to be_falsy
          expect(attached_tex.code).to eq Settings.tex_default_code
          expect(File.exist?(Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf"))).to be_falsy
        end
      end
    end

    describe "compile_result_path" do
      let!(:attached_tex) { create(:tex, :with_attachment, compile_result_url: "http://localhost:3000/#{Settings.dir.compile_result}/test_new.pdf", texable: question) }

      it "compile_result_urlを内部pathに変換できること" do
        expect(attached_tex.compile_result_path).to eq Rails.root.join("public/#{Settings.dir.compile_result}/test_new.pdf")
      end
    end
  end
end
