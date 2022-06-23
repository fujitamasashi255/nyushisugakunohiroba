# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id                 :uuid             not null, primary key
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
class Tex < ApplicationRecord
  belongs_to :texable, polymorphic: true
  has_one_attached :pdf

  attribute :code, :text, default: Settings.tex_default_code

  validates \
    :pdf, \
    content_type: "application/pdf", \
    size: { less_than: 1.megabytes, message: "のサイズは1MB以下にして下さい" }, \
    limit: { max: 1, message: "は1つ以下にして下さい" }

  def attach_pdf
    if pdf_blob_signed_id?
      pdf.attach(pdf_blob_signed_id)
    elsif pdf.attached?
      pdf.purge
    end
  end

  # texオブジェクトに対し、そのpdfをpngに変換し余白を取り除いたファイルのblobを返す
  def pdf_to_img_blob
    return if pdf.blank? || texable_type != "Question"

    # 作成前にあるimg_blobを削除
    texable.image.purge if texable.image.present?

    # 変換して得られるpngファイルのパス、名前（拡張子除く）を取得
    image_path = "#{Settings.tmp_image_dir}#{Time.current.strftime('%Y%m%d%H%M%S')}.png"
    image_name = File.basename(image_path, ".*")
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
    img_vip.write_to_file image_path, Q: 100, compression: 9

    # blobを作成
    ActiveStorage::Blob.create_and_upload!(io: File.open(image_path), filename: image_name)
  end

  # texオブジェクトの属性を空にする
  def clear_attributes
    pdf.purge
    self.code = Settings.tex_default_code
    self.pdf_blob_signed_id = nil
  end
end
