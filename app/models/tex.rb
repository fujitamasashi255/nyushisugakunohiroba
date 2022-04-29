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
#  texable_id         :bigint           not null
#
# Indexes
#
#  index_texes_on_texable  (texable_type,texable_id)
#
class Tex < ApplicationRecord
  belongs_to :texable, polymorphic: true
  has_one_attached :pdf

  attribute :code, :text, default: Settings.tex_default_code

  def attach_pdf
    pdf.attach(pdf_blob_signed_id) if pdf_blob_signed_id?
  end

  # texオブジェクトに対し、そのpdfをpngに変換し余白を取り除いたファイルのblobを返す
  def pdf_to_img_blob
    return if pdf.blank?

    # pdfファイルの名前を取得
    image_name = File.basename(pdf.blob.filename.to_s, ".*")
    # pdfファイルのパスを取得
    image_path = Rails.root.join("tmp/rails-latex/#{image_name}.png").to_s
    # pdfファイルをpngファイルへ変換
    pdf_vip = Vips::Image.pdfload ActiveStorage::Blob.service.path_for(pdf.key), dpi: 600
    pdf_vip.write_to_file image_path, Q: 100
    img_vip = Vips::Image.new_from_file(image_path)

    # pngファイルの余白を削除
    # 右余白は左余白と同じだけ削除する
    image_width = img_vip.width
    extract_amount = img_vip.find_trim
    extract_amount[2] = image_width - extract_amount[0] * 2
    left, top, width, height = extract_amount
    img_vip = img_vip.extract_area(left, top, width, height)
    img_vip.write_to_file image_path, Q: 100

    # blobを作成
    ActiveStorage::Blob.create_and_upload!(io: File.open(image_path), filename: image_name)
  end
end
