import {previewFile} from "src/self_made/FilePreview"

$(function(){
  const fileInput = $("#user-avatar-input");
  fileInput.on("change", function(e){
    var file = e.target.files[0];
    const preview = $("#avatar-preview");
    preview.empty();
    previewFile(file, null, preview);
  });
})
