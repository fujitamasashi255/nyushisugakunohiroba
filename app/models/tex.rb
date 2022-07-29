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
class Tex < ApplicationRecord
  MAX_PDF_SIZE = 1.megabytes

  belongs_to :texable, polymorphic: true
  has_one_attached :pdf

  attribute :code, :text, default: Settings.tex_default_code
  attribute :compile_result_url, :string, default: ""

  validates \
    :pdf, \
    content_type: "application/pdf", \
    size: { less_than: MAX_PDF_SIZE, message: "のサイズは1MB以下にして下さい" }, \
    limit: { max: 1, message: "は1つ以下にして下さい" }

  def attach_pdf
    if compile_result_url.present?
      pdf.attach(io: File.open(compile_result_path), filename: File.basename(compile_result_path), content_type: "application/pdf") if File.file?(compile_result_path) && File.exist?(compile_result_path)
    elsif pdf.attached? & (texable_type == "Answer")
      pdf.purge
    end
  end

  # texオブジェクトの属性を空にする
  def restore
    pdf.purge
    self.code = Settings.tex_default_code
    File.delete(compile_result_path) if File.file?(compile_result_path) && File.exist?(compile_result_path)
    self.compile_result_url = ""
  end

  # 外部からpdfにアクセスするurl tex.compile_result_url を
  # 内部からpdfにアクセスする tex.compile_result_path へ変換
  def compile_result_path
    Rails.root.join("public/#{Settings.dir.compile_result}/#{File.basename(compile_result_url)}")
  end
end
