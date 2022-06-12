import {previewFile} from "src/self_made/FilePreview"

$(function(){
  const fileInput = $("#user-avatar-input");
  fileInput.on("change", function(e){
    var file = e.target.files[0];
    if(file){
      const preview = $("#avatar-preview");
      preview.empty();
      previewFile(file, null, preview);
    }
    /*const submitButton = $(".user-form input[type='submit']")
    if(file.size > 1000000){
      submitButton.prop('disabled', true);
      console.log("1MB以上");
    }else{
      submitButton.prop('disabled', false);
    }
    */
  });
})
