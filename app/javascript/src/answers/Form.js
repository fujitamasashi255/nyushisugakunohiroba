import { previewFile } from "src/PreviewFile"
import { complessAndUpload } from "src/compressAndDirectUpload"
import { toggleCollapseMessage } from "src/collapse"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

const default_tex_code = "\\documentclass[12pt, dvipdfmx]{jsarticle}\n\\usepackage{amssymb, amsmath, tikz, enumerate}\n\\usetikzlibrary{intersections, calc, arrows.meta, math}\r\n\\usepackage[margin=1cm]{geometry}\r\n\\pagestyle{empty}\r\n\r\n\\begin{document}\r\n\r\n\\end{document}"
const carouselInnerHeight = "550px";
const maxFileSize = 3 * 1024 * 1024;
const maxFileNumber = 3;

// ファイルサイズが maxFileSize 以下であることを確認
const isValidFileSize = (file) => file.size <= maxFileSize;

//プレビューファイルの有無で、carouselInnerの高さを変える
const adjustCarouselInnerHeight = function(carouselInner){
  if(carouselInner.find(".carousel-item").length >= 1){
    // プレビューファイルあり
    carouselInner.attr("style", `height: ${carouselInnerHeight}`);
  }
}

// filesのダイレクトアップロード用hiddenfieldを削除
function deleteHiddenFilesInput(){
  const hiddenFields = document.querySelectorAll('input[type=hidden][class="direct-upload"]');
  if(hiddenFields.length > 0){
    hiddenFields.forEach( el => {
      el.remove();
    });
  }
}

// ファイルプレビューをクリア
function clearPreview(){
  // ファイルクリアボタン
  const deleteFilesButton = $("#delete-files-button");
  // プレビューの内容
  const preview = $(".files .preview");

  deleteFilesButton.empty();
  preview.empty();
  // filesのダイレクトアップロード用hiddenfieldを削除
  deleteHiddenFilesInput();
}


// ファイルプレビュー
function previewAnswerFiles(files){
  if(files.length > 0){
    // ファイルプレビュー
    $.each(files, async function(idx, file){
      var fileWrapper = $(".preview .file").eq(idx);
      await previewFile(file, fileWrapper);
    });
  }
}

// プレビューの外枠を作成（ここに画像を入れていく）
function buildPreview(number){
  const deleteFilesIcon = $("<i class='bi bi-x-lg'></i>");
  $("#delete-files-button").append(deleteFilesIcon);
  const preview = $(".files .preview");
  if(number > 1){
    for(var i = 1; i <= number; i++){
      var fileContainer = $("<div>", { class: "file-container col-lg-4 d-flex flex-lg-column align-items-center mt-4 mt-lg-0" });
      // 順番選択セレクトボックス
      var orderSelectContainer = $("<div>", { class: "order-select-container d-flex align-items-center text-nowrap"});
      var selectboxContainer = $("<div>", { class: "selectbox-container" });
      var selectBox = $("<select>", { class: "form-control select required text-center", name: "" });
      for(var j = 1; j <= number; j++){
        if(j == i){
          selectBox.append($("<option>", { value: j, text: j, selected: true }));
        }else{
          selectBox.append($("<option>", { value: j, text: j }));
        }
      }
      selectboxContainer.append(selectBox);
      var suffix = $("<div>", { class: "suffix ms-1", text: "番目"});
      var answerFile = $("<div>", { class: "file mt-lg-2 ms-4 ms-lg-0" });
      fileContainer.append(orderSelectContainer.append(selectboxContainer).append(suffix));
      fileContainer.append(answerFile);
      fileContainer.appendTo(preview);
    }
  }else if(number == 1){
    var fileContainer = $("<div>", { class: "file-container col-lg-4 d-flex flex-lg-column align-items-center mt-4 mt-lg-0" });
    var answerFile = $("<div>", { class: "file mt-lg-2 ms-4 ms-lg-0" });
    fileContainer.append(answerFile);
    fileContainer.appendTo(preview);
  }
}


document.addEventListener("DOMContentLoaded", function(){
  //オフキャンバス開閉時
  if(document.querySelector('#questionImageDropdownButton')){
    var offcanvasHumberger = document.querySelector("#offcanvasHumberger")
    var icons = document.querySelector(".answer-top-icons")
    // オフキャンバスがひれかれた時
    offcanvasHumberger.addEventListener("show.bs.offcanvas", function(){
      // 問題文ドロップダウンが開いているときは閉じる
      new bootstrap.Dropdown("#questionImageDropdownButton").hide();
      // 解答ページの右上アイコンを非表示にする
      icons.style.visibility ="hidden";
    });
    // オフキャンバスが閉じたとき
    offcanvasHumberger.addEventListener("hidden.bs.offcanvas", function(){
      // 解答ページの右上アイコンを表示する
      icons.style.visibility ="visible";
    });
  }

  const input = document.querySelector('.answer-form .files input[type=file]');

  // ファイル関連
  if(input){
    // ファイルを登録したら
    input.addEventListener('change', (event) => {
      // エラーメッセージを削除
      const errorMessage = $(".error_message")
      if (errorMessage){
        errorMessage.remove();
      }

      // ファイルプレビュー → 画像圧縮 → ダイレクトアップロード
      const files = Array.from(event.target.files);
      clearPreview();
      if(files.every(isValidFileSize) && files.length <= maxFileNumber){
        buildPreview(files.length);
        previewAnswerFiles(files);
        complessAndUpload(files);
      }else if(files.length > maxFileNumber){
        // ファイルが適切でない場合にメッセージを表示
        $(".preview").append(`<div class='error_message'>${t("javascript.answers.form.files.error_message.many")}</p>`)
      }else{
        // ファイルが適切でない場合にメッセージを表示
        $(".preview").append(`<div class='error_message'>${t("javascript.answers.form.files.error_message.large")}</p>`)
      }
      // inputに登録されているファイルを削除
      $(input).val(null);
    });

    // ファイル順番セレクトボックス
    // 選択した値と同じ値をもつセレクトボックスの値を、
    // 選択されたセレクトボックスの値の元の値に変更する
    var selectBoxValues = [1, 2, 3];
    $(document).on("input", $(".files select"), (event) => {
      var selectedIdx = $(".files select").index(event.target);
      var preValue = selectBoxValues[selectedIdx];
      var selectValue = Number(event.target.value);
      var changeIdx = selectBoxValues.indexOf(selectValue);
      selectBoxValues[selectedIdx] = selectValue;
      selectBoxValues[changeIdx] = preValue;
      $(".files select").eq(changeIdx).val(preValue);
    });

    // ファイルクリアボタン
    const deleteFilesButton = $("#delete-files-button");

    // 登録ファイル削除
    if(deleteFilesButton){
      // ファイル削除ボタンを押したら
      deleteFilesButton.on("click", function(){
        if(!confirm('登録したファイルを削除しますか')){
          // キャンセルの時の処理
          return false;
        }else{
          // DBに登録されているファイルを削除
          var path = $(this).data("deleteFilesPath");
          if(path){
            $.ajax({url: path, type: 'DELETE'});
          }
          // プレビューをクリアー
          clearPreview();
          // files のinputをクリア
          $(input).val(null);
        }
      });
    }
  }


  // TeXのおりたたみ
  const collapseElem = document.querySelector("#texField");
  const collapseLink = document.querySelector("a[href='#texField']");
  // ページ読み込み時にTeXファイルがあるときは、折りたたみを開く
  if($("#compile-result").children("iframe").length){
    new bootstrap.Collapse('.answer-form .collapse').show();
  }

  if(collapseElem){
    toggleCollapseMessage(collapseElem, collapseLink, t("javascript.answers.form.tex_collapse.open"), t("javascript.answers.form.tex_collapse.close"));
  }
});



$(function(){
  // TeXクリアボタン
  const deleteTeXButton = $("#delete-tex-button");
  // TeX削除ボタンを押したら
  $(deleteTeXButton).on("click", function(){
    if(!confirm('TeXのコード、コンパイル結果を削除しますか')){
      // キャンセルの時の処理
      return false;
    }else{
      // OKの時の処理
      var path = $(this).data("delete-tex-path");
      $(this).data("delete-tex-path", null);
      // pdf_blob_signed_idをリセット
      $("#compile_result_url").val("");
      $("#compile-result").empty();
      var compileMessage = $("#compile-message");
      if(compileMessage){
        compileMessage.remove();
      }
      $("#tex-code").val(default_tex_code);
      if(path){
        $.ajax({url: path, type: 'DELETE'});
      }
    }
  });
});

/*
  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");

  if(carouselInner){
    // ファイル数に応じてcarouselInnerの高さを調整
    adjustCarouselInnerHeight(carouselInner);

    */
