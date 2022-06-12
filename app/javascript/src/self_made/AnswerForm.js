import {previewFile} from "src/self_made/FilePreview"

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
    nextButton.addEventListener("click", function(){
      carouselObj.next();
    });
    prevButton.addEventListener("click", function(){
      carouselObj.prev();
    });
  }


  // ツールチップを許可
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
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
    MathJax.typeset($("#tab-point-result").html(pointCode));
    removeBrTagsAfterDisplayMath();
  });

  // ファイルのプレビュー
  const fileInput = $("#answer-files-input");
  // プレビュー画像を追加する要素
  const carouselInner = $(".files .carousel-inner");
  const carouselPrevDiv = $(".files .carousel-prev div");
  const carouselNextDiv = $(".files .carousel-next div");

  // input[type=file]でファイルを読み込んだら実行
  fileInput.on("change", function(e){
    const carouselItem = $("<div class='carousel-item'></div>");
    const carouselItemActive = $("<div class='carousel-item active'></div>");
    carouselInner.empty();
    carouselPrevDiv.empty();
    carouselNextDiv.empty();
    var files = e.target.files; // 読み込んだファイル
    $.each(files, function(idx, file){
      if(idx == 0){
        previewFile(file, carouselItemActive, carouselInner);
      }else{
        previewFile(file, carouselItem, carouselInner);
      }
    });
    // 読み込んだファイル数が2つ以上の時、carouselコントローラ を表示する
    if(files.length >= 2){
      carouselNextDiv.append("<span class='carousel-control-next-icon'>");
      carouselPrevDiv.append("<span class='carousel-control-prev-icon'>");
    }
  });
});
