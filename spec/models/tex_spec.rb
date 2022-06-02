# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id                 :bigint           not null, primary key
#  code               :text
#  texable_type       :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  pdf_blob_signed_id :string
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
    let(:attached_tex) { create(:tex, :with_attachment, texable: question) }

    describe "pdf_to_img_blob" do
      it "attachされているpdfをpngに変換したものが取得できること" do
        image = attached_tex.pdf_to_img_blob
        expect(image.content_type).to eq "image/png"
      end
    end

    describe "attach_pdf" do
      it "pdfファイルを、そのActiveStorage::Blobを介してtexにattachできること" do
        file_path = Rails.root.join("spec/files/rspec_test.pdf")
        file_name = "rspec_test.pdf"
        blob = ActiveStorage::Blob.create_and_upload!(io: File.open(file_path), filename: file_name)
        tex = create(:tex, pdf_blob_signed_id: blob.signed_id, texable: question)
        tex.attach_pdf
        expect(tex.pdf.attached?).to be_truthy
      end

      it "pdf_blob_signed_idがnilのとき、attachされているpdfが削除されること" do
        attached_tex.pdf_blob_signed_id = nil
        attached_tex.attach_pdf
        expect(attached_tex.pdf.attached?).to be_falsy
      end
    end
  end
end
