# frozen_string_literal: true

class TexCompilesController < ApplicationController
  def create
    code = params[:code]
    pdf_url = params[:pdf_url]

    old_pdf_path = Rails.root.join("public/#{Settings.dir.compile_result}/#{File.basename(pdf_url)}")
    # コンパイル前のpdfを削除
    file_delete_if_exist(old_pdf_path)

    # codeをコンパイルする
    begin
      # コンパイル結果のバイナリ
      pdf_binary = LatexToPdf.generate_pdf(code, LatexToPdf.config)
      # コンパイルして得られるpdfのパス
      file_name = "#{current_user.id}#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
      new_pdf_path = Rails.root.join("public/#{Settings.dir.compile_result}/#{file_name}")
      File.open(new_pdf_path, "w+b") do |f|
        f.write(pdf_binary)
      end

      # プレビュー表示するpdfのurl
      compile_result_url = "#{root_url}/#{Settings.dir.compile_result}/#{file_name}"
      # JSへ compile_result_url を返す
      render json: { url: compile_result_url }
    rescue RailsLatex::ProcessingError => e
      # コンパイル失敗時はログの内容の文字列を返し、compile_result_urlを""に設定
      render json: { log_text: e.log, url: "" }
    end
  end
end
