import {previewAvatar} from "src/self_made/PreviewFile"


$(function(){
  // プロフィール画像のプレビュー
  const fileInput = $("#user-avatar-input");
  fileInput.on("change", function(e){
    var file = e.target.files[0];
    if(file){
      const preview = $("#avatar-preview");
      preview.empty();
      previewAvatar(file, preview);
    }
  });
})
