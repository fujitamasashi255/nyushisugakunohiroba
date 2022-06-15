// 読み込みを許可するファイルタイプ
export const validImageType = ["image/png", "image/jpg"];
export const pdfType = "application/pdf";

// previewFileメソッド
export const previewFile = function(file, wrapper, preview){
  // FileReaderオブジェクトを作成
  const reader = new FileReader();

  // ファイルが読み込まれたときに実行する
  reader.onload = function (e) {
    // ファイルのURLを取得
    const fileUrl = e.target.result;
    if(validImageType.includes(file.type)){
      // 画像ファイルの時
      var fileTag = $("<img>");
      fileTag.attr("class", "d-block img-fluid");
    }else if(file.type == pdfType){
      // PDFのとき
      var fileTag = $("<embed>");
      fileTag.attr("type", "application/pdf");
    }
    fileTag.attr("src", fileUrl); // ファイルのURLをfileTagにセット
    (fileTag).appendTo(preview); // fileTagを#previewの中に追加
    // wrapperがあれば、fileTagをwrapperでラップする
    if(wrapper){
      fileTag.wrap(wrapper);
    }
  }

  // ファイルを読み込む
  reader.readAsDataURL(file);
}
