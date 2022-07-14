import {previewFile} from "src/PreviewFile"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

const default_tex_code = "\\documentclass[12pt, dvipdfmx]{jsarticle}\n\\usepackage{amssymb, amsmath, tikz, enumerate}\n\\usetikzlibrary{intersections, calc, arrows.meta, math}\r\n\\usepackage[margin=1cm]{geometry}\r\n\\pagestyle{empty}\r\n\r\n\\begin{document}\r\n\r\n\\end{document}"

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
      collapseLink.textContent = t("javascript.answer_form.tex_collapse.open");
      collapseLink.append(Icon);
    });
    collapseElem.addEventListener("show.bs.collapse", function(){
      collapseLink.innerHTML = "";
      var Icon = document.createElement("i");
      Icon.setAttribute("class", "bi bi-chevron-up ms-2");
      collapseLink.textContent = t("javascript.answer_form.tex_collapse.close");
      collapseLink.append(Icon);
    });
  }
});

////////////////////////////JQuery////////////////////////////

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
