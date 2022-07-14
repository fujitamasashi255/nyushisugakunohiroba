import imageCompression from 'browser-image-compression'
import { DirectUpload } from "@rails/activestorage"
import { previewFile } from "src/PreviewFile"

// 読み込みを許可するファイルタイプ
const compressedContentType = ["image/png", "image/jpeg", "image/jpg"];
const pdfType = "application/pdf";
const carouselInnerHeight = "550px";
const maxFileSize = 3 * 1024 * 1024;

document.addEventListener("DOMContentLoaded", function(){
  const input = document.querySelector('.answer-form .files input[type=file]');
  // ファイルクリアボタン
  const deleteFilesButton = $("#delete-files-button");
  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");

  if(carouselInner){
    // ファイル数に応じてcarouselInnerの高さを調整
    adjustCarouselInnerHeight(carouselInner);
  }

  // ファイルプレビュー → 画像圧縮 → ダイレクトアップロード
  if(input){
    input.addEventListener('change', (event) => {
      // エラーメッセージを削除
      const errorMessage = $(".error_message")
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

      // プレビュー → アップロード
      const files = Array.from(event.target.files);
      if(files.every(isValidFile)){
        PreviewFiles(files);
        complessAndUpload(files)
      }else{
        clearPreview();
        // ファイルが適切でない場合にメッセージを表示
        $(".preview").append("<div class='error_message my-auto'>アップロードできるファイルの最大サイズは3MBです</p>") //エラーメッセージ表示
      }
    });
  }

  // 登録ファイル削除
  if(deleteFilesButton){
    // ファイル削除ボタンを押したら
    deleteFilesButton.on("click", function(){
      if(!confirm('登録したファイルを削除しますか')){
        // キャンセルの時の処理
        return false;
      }else{
        // DBに登録されているファイルを削除
        var path = $(this).data("delete-files-path");
        if(path){
          $.ajax({url: path, type: 'DELETE'});
        }
        clearPreview();
      }
    });
  }
});

// 関数定義
// ファイルサイズが validFileSize より小さいことを確認
const isValidFile = (file) => file.size <= maxFileSize;

// ファイルプレビューをクリア
function clearPreview(){
  const input = document.querySelector('.answer-form .files input[type=file]');
  // ファイルクリアボタン
  const deleteFilesButton = $("#delete-files-button");
  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");
  // カルーセルコントローラ
  const carouselPrevDiv = $(".files .carousel-prev div");
  const carouselNextDiv = $(".files .carousel-next div");
  const carouselIndicators = $(".files .indicators-wrapper");

  // inputに登録されているファイルを削除
  $(input).val(null);
  // ファイル登録前のカルールの内容、コントローラ、インディケーター、ファイル削除アイコンをクリア
  carouselInner.empty();
  carouselPrevDiv.empty();
  carouselNextDiv.empty();
  deleteFilesButton.empty();
  carouselIndicators.empty();
  // carouselInnerの高さを調整
  carouselInner.attr("style", "height: inherit");
}


// ファイルプレビュー
function PreviewFiles(files){
  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");

  // カルーセルコントローラ
  const carouselPrevDiv = $(".files .carousel-prev div");
  const carouselNextDiv = $(".files .carousel-next div");
  const carouselIndicators = $(".files .indicators-wrapper");
  const carouselItem = $("<div class='carousel-item'></div>");
  const carouselItemActive = $("<div class='carousel-item active'></div>");
  // ファイルクリアボタン
  const deleteFilesButton = $("#delete-files-button");
  const deleteFilesIcon = $("<i class='bi bi-x-lg'></i>");

  if(files.length > 0){
    // ファイル登録前のカルーセルの内容、コントローラ、インディケータをクリア
    carouselInner.empty();
    carouselPrevDiv.empty();
    carouselNextDiv.empty();
    deleteFilesButton.empty();
    carouselIndicators.empty();
    deleteFilesButton.append(deleteFilesIcon);
    // carouselInnerの高さを調整
    carouselInner.attr("style", `height: ${carouselInnerHeight}`);

    // ファイルプレビュー
    $.each(files, async function(idx, file){
      if(idx == 0){
        await previewFile(file, carouselItemActive, carouselInner);
      }else{
        await previewFile(file, carouselItem, carouselInner);
      }
    });
  }

  // 読み込んだファイル数が2つ以上の時、carouselコントローラ、インディケーター を表示する
  if(files.length >= 2){
    // コントローラ
    carouselNextDiv.append("<span class='carousel-control-next-icon'>");
    carouselPrevDiv.append("<span class='carousel-control-prev-icon'>");
    // インディケーター
    carouselIndicators.append("<div class='mx-1 indicator'><i class='bi bi-circle-fill'>");
    for(var i=0; i < files.length-1; i++){
      carouselIndicators.append("<div class='mx-1 indicator'><i class='bi bi-circle'>");
    }
  }
}

// 画像圧縮 → ダイレクトアップロード
function complessAndUpload(files){
  files.forEach(async file => {
    if(compressedContentType.includes(file.type)){
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
        await uploadFile(compressedFile);
      } catch (error) {
        console.log(error);
      }
    }else if(file.type == pdfType){
      // PDFのときは圧縮しない
      try {
        await uploadFile(file);
      } catch (error) {
        console.log(error);
      }
    }
  });
}

// ファイルアップロード
const uploadFile = (file) => {
  const input = document.querySelector('.answer-form .files input[type=file]');
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


//プレビューファイルの有無で、carouselInnerの高さを変える
const adjustCarouselInnerHeight = function(carouselInner){
  if(carouselInner.find(".carousel-item").length >= 1){
    // プレビューファイルあり
    carouselInner.attr("style", `height: ${carouselInnerHeight}`);
  }
}

