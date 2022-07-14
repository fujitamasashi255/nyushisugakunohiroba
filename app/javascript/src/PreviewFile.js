// 読み込みを許可するファイルタイプ
export const validImageType = ["image/png", "image/jpeg", "image/jpg"];
export const pdfType = "application/pdf";

// previewFileメソッド
// file を wrapper で囲まれたpreview に表示
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
      fileTag.attr("style", "max-width: 100%; max-height: 500px");
      fileTag.attr("loading", "lazy");
    }else if(file.type == pdfType){
      // PDFのとき
      var fileTag = $("<iframe>");
      fileTag.attr("type", "application/pdf");
      fileTag.attr("loading", "lazy");
      fileTag.attr("marginheight", "0");
      fileTag.attr("marginwidth", "0");
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


// previewAvatarメソッド
export const previewAvatar = function(file, preview){
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
      fileTag.attr("style", "width: 80px; height: 80px");
      fileTag.attr("loading", "lazy");
    }
    fileTag.attr("src", fileUrl); // ファイルのURLをfileTagにセット
    (fileTag).appendTo(preview); // fileTagを#previewの中に追加
  }

  // ファイルを読み込む
  reader.readAsDataURL(file);
}
