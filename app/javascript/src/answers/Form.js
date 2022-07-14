import { previewFile } from "src/PreviewFile"
import { complessAndUpload } from "src/compressAndDirectUpload"

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
function previewAnswerFiles(files){
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


document.addEventListener("DOMContentLoaded", function(){
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

  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");

  if(carouselInner){
    // ファイル数に応じてcarouselInnerの高さを調整
    adjustCarouselInnerHeight(carouselInner);
  }

  const input = document.querySelector('.answer-form .files input[type=file]');
  // ファイルクリアボタン
  const deleteFilesButton = $("#delete-files-button");

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
      if(files.every(isValidFileSize) && files.length <= maxFileNumber){
        previewAnswerFiles(files);
        complessAndUpload(input)
      }else if(files.length > maxFileNumber){
        clearPreview();
        // ファイルが適切でない場合にメッセージを表示
        $(".preview").append(`<div class='error_message'>${t("javascript.answers.form.files.error_message.many")}</p>`)
      }else{
        clearPreview();
        // ファイルが適切でない場合にメッセージを表示
        $(".preview").append(`<div class='error_message'>${t("javascript.answers.form.files.error_message.large")}</p>`)
      }
    });
  }

  // カルーセル
  var carousel = document.querySelector('.carousel');
  if(carousel){
    var carouselObj = new bootstrap.Carousel('#carouselAnswerFiles');
    var nextButton = document.querySelector('.carousel-next');
    var prevButton = document.querySelector('.carousel-prev');
    if(nextButton){
      // ボタンを押すとスライド
      nextButton.addEventListener("click", function(){
        carouselObj.next();
      });
      prevButton.addEventListener("click", function(){
        carouselObj.prev();
      });
      // スライドするとインディケーターを変化させる
      carousel.addEventListener('slide.bs.carousel', event => {
        var nextIndicator = document.querySelectorAll('.indicator i').item(event.to);
        var currentIndicator = document.querySelectorAll('.indicator i').item(event.from);
        nextIndicator.classList.remove("bi-circle");
        nextIndicator.classList.add("bi-circle-fill");
        currentIndicator.classList.remove("bi-circle-fill");
        currentIndicator.classList.add("bi-circle");
      });
    }
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


  // TeXのおりたたみ
  var collapseElem = document.querySelector("#texField");
  var collapseLink = document.querySelector("a[href='#texField']");
  // ページ読み込み時にTeXファイルがあるときは、折りたたみを開く
  if($("#compile-result").children("iframe").length){
    new bootstrap.Collapse('.answer-form .collapse').show();
  }
  // 折りたたみボタンを押した時の処理
  if(collapseElem){
    collapseElem.addEventListener("hide.bs.collapse", function(){
      collapseLink.innerHTML = "";
      var Icon = document.createElement("i");
      Icon.setAttribute("class", "bi bi-chevron-down ms-2");
      collapseLink.textContent = t("javascript.answers.form.tex_collapse.open");
      collapseLink.append(Icon);
    });
    collapseElem.addEventListener("show.bs.collapse", function(){
      collapseLink.innerHTML = "";
      var Icon = document.createElement("i");
      Icon.setAttribute("class", "bi bi-chevron-up ms-2");
      collapseLink.textContent = t("javascript.answers.form.tex_collapse.close");
      collapseLink.append(Icon);
    });
  }
});

// MathJaxによる数式表示時、ディスプレー数式の直後のbrは削除する
var removeBrTagsAfterDisplayMath = function(){
  $('mjx-container[display="true"]').next().each(function(){
    if($(this).is("br")){
        $(this).remove();
    }
  });
}


$(function(){
  // ポイントのプレビュー
  removeBrTagsAfterDisplayMath();
  $(".answer-form a[href='#tab-point-result']").on("click", function(){
    var pointCode = $("#tab-point-code trix-editor").html();
    // 数式番号をリセット
    MathJax.texReset([0]);
    // 数式をタイプセット
    MathJax.typeset($("#tab-point-result").html(pointCode));
    removeBrTagsAfterDisplayMath();
  });

  // TeXクリアボタン
  const deleteTeXButton = $("#delete-tex-button");
  const deleteTeXIcon = $("<i class='bi bi-x-lg'></i>");
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
