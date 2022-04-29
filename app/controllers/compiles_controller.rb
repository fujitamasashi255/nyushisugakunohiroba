# frozen_string_literal: true

class CompilesController < ApplicationController
  def create
    code = params[:code]
    signed_id = params[:id]
    # コンパイル前のblobを削除
    old_blob = ActiveStorage::Blob.find_signed(signed_id)
    old_blob.purge if old_blob.present?

    begin
      pdf_binary = LatexToPdf.generate_pdf(code, LatexToPdf.config)
      pdf_path = Rails.root.join("tmp/rails-latex/tex#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf")
      File.open(pdf_path, "w+b") do |f|
        f.write(pdf_binary)
      end
      blob = ActiveStorage::Blob.create_and_upload!(io: File.open(pdf_path), filename: File.basename(pdf_path))
      render json: { url: url_for(blob), signed_id: blob.signed_id }
    rescue RailsLatex::ProcessingError => e
      render json: { log_text: e.log, signed_id: nil }
    end
  end
end
