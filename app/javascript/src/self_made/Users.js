import {previewFile} from "src/self_made/FilePreview"


$(function(){
  // プロフィール画像のプレビュー
  const fileInput = $("#user-avatar-input");
  fileInput.on("change", function(e){
    var file = e.target.files[0];
    if(file){
      const preview = $("#avatar-preview");
      preview.empty();
      previewFile(file, null, preview);
    }
  });
})
