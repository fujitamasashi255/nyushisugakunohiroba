import { previewAvatar } from "src/PreviewFile"
import { complessAndUpload } from "src/compressAndDirectUpload"

// ファイルの最大サイズ
const maxFileSize = 3 * 1024 * 1024;
// ファイルサイズが maxFileSize 以下であることを確認
const isValidFileSize = (file) => file.size <= maxFileSize;

$(function(){
  // プロフィール画像のプレビュー
  const input = document.getElementById("user-avatar-input")
  $(input).on("change", function(e){
    // エラーメッセージを削除
    const errorMessage = $(".error-message")
    if (errorMessage){
      errorMessage.remove();
    }
    // 既にあるhiddenfieldを削除
    const hiddenFields = document.querySelectorAll('.files input[type=hidden]');
    if(hiddenFields.length > 0){
      hiddenFields.forEach( el => {
        el.remove();
      });
    }
    // プレビューを削除
    const preview = $("#avatar-preview");
    preview.empty();

    var file = e.target.files[0];
    if(isValidFileSize(file)){
      previewAvatar(file, preview);
      complessAndUpload([file]);
    }else {
      // ファイルが適切でない場合にメッセージを表示
      preview.append("<div class='error-message note'>アップロードできるファイルの最大サイズは3MBです</p>")
    }
  });
})
