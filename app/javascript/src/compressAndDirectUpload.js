import imageCompression from 'browser-image-compression'
import { DirectUpload } from "@rails/activestorage"
import { validImageType } from "src/PreviewFile"
import { pdfType } from "src/PreviewFile"

// 画像圧縮 → ダイレクトアップロード
export const complessAndUpload = function(input){
  Array.from(input.files).forEach(async file => {
    if(validImageType.includes(file.type)){
      console.log('originalFile instanceof Blob', file instanceof Blob); // true
      console.log(`originalFile size ${file.size / 1024 / 1024} MB`);

      const options = {
        maxSizeMB: 1, // 最大ファイルサイズ
        maxWidthOrHeight: 500 // 最大画像幅もしくは高さ
      }
      try {
        // 画像圧縮
        const compressedFile = await imageCompression(file, options);
        console.log('compressedFile instanceof Blob', compressedFile instanceof Blob); // true
        console.log(`compressedFile size ${compressedFile.size / 1024 / 1024} MB`); // smaller than maxSizeMB

        // ダイレクトアップロード
        await uploadFile(compressedFile, input);
      } catch (error) {
        console.log(error);
      }
    }else if(file.type == pdfType){
      // PDFのときは圧縮しない
      try {
        await uploadFile(file, input);
      } catch (error) {
        console.log(error);
      }
    }
  });
}

// ファイルアップロード
const uploadFile = (file, input) => {
  // フォームではfile_field direct_upload: trueが必要
  // （これでdata-direct-upload-url、
  // data-direct-upload-token、
  // data-direct-upload-attachment-nameを提供する）
  const url = input.dataset.directUploadUrl
  const token = input.dataset.directUploadToken
  const attachmentName = input.dataset.directUploadAttachmentName
  const upload = new DirectUpload(file, url, token, attachmentName)

  upload.create((error, blob) => {
    if (error) {
      // エラーハンドリングをここに書く
    } else {
      // 適切な名前のhidden inputをblob.signed_idの値とともにフォームに追加する
      // これによりblob idが通常のアップロードフローで転送される
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      console.log(blob);
      hiddenField.name = input.name
      document.querySelector('.files').appendChild(hiddenField)
    }
  });

  // 選択されたファイルをここで入力からクリアしてもよい
  input.value = null;
}




