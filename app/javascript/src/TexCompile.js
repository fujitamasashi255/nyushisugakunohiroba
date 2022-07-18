// called from views/texes/_form

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

// PDFを作成するコントローラpdfs_controllerへのパス path
const pdfsPath = "/tex_compile";

// pdfUrlのファイルをrenderElementに表示する
var renderPdf = function(pdfUrl, renderElement){
  $('<iframe>', { loading: "lazy", type: "application/pdf", marginheight: "0", marginwidth: "0" }).attr('src', pdfUrl).appendTo(renderElement);
}

// logTextをrenderElementに表示する
var renderLogText = function(logText, renderElement){
  $('<div>', { id: "log-text", class: "p-2" }).html(logText).appendTo(renderElement);
}

// 「コンパイル中」ボタンにする
var disabledButton = function(button){
  button.addClass("disabled").empty().text(t("javascript.tex_compile.compiling"));
  var disabledDisplay = $('<span>', {class: "spinner-border spinner-border-sm mr-1", role: "status", aria: {hidden: "true"}});
  button.prepend(disabledDisplay);
}

// 「コンパイルする」ボタンに戻す
var replacewithNewButton = function(button, compileResultUrl){
  var newButton = $('<button>', {class: "btn btn-outline-dark", id: "compile-button", type: "button"}).text(t("javascript.tex_compile.compile"));
  button.replaceWith(newButton)
  if(compileResultUrl){
    $('<span>', {id: "compile-message", class: "text-success ms-2 d-inline-block"}).text(t("javascript.tex_compile.success")).insertAfter(newButton);
  }else{
    $('<span>', {id: "compile-message", class: "text-danger ms-2 d-inline-block"}).text(t("javascript.tex_compile.fail")).insertAfter(newButton);
  }
}

// コンパイルをリクエストするajax通信を実行し、その結果を表示する
var compileAjax = function(path, code, pdfUrlElement, compileResultElement){
  $.post(path, {code: code, pdf_url: pdfUrlElement.val()}, null, "json").done(function(data, statusText, jqXHR){
    //  コンパイル結果のBlobオブジェクトのsigned_idを設定
    pdfUrlElement.val(data.url);
    if(Boolean(data.url)){
      // コンパイル成功時
      // 帰ってくるデータ data = json: { url: compile_result_url }
      // コンパイル結果のpdfのurl
      var pdfUrl = data.url;
      // コンパイル結果をcompileResultElementに表示する
      renderPdf(pdfUrl, compileResultElement);
    }else{
      // コンパイル失敗時
      // 帰ってくるデータ data = json: {log_text: e.log, url: nil}
      // ログのテキスト logText
      var logText = data.log_text;
      // logTextをcompileResultElementに表示する
      renderLogText(logText, compileResultElement);
    }
  }).fail(function(jqXHR, statusText, error){
    // 失敗時
    const errorText = t("javascript.tex_compile.error_text")
    renderLogText(errorText, compileResultElement);
    //console.log(`jqXHR: ${jqXHR.status}`);
    //console.log(`textStatus: ${textStatus}`);
    //console.log(`error: ${error}`);
  })
}


$(function(){
  $(document).on('click', "#compile-button", function(){
    var button = $(this);
    var submitButton = $("input[type='submit']");
    // コンパイルするtexコード Code
    var code = $('#tex-code').val();
    // 要素 t.input_field :compile_result_url を取得
    var pdfUrlElement = $('#compile_result_url');
    // コンパイル結果を表示する要素 compileResultElement
    var compileResultElement = $('#compile-result');

    // compileResultElement を空にする
    compileResultElement.empty();
    // #compile-messageを消去
    $("#compile-message").remove();

    // ボタンを「コンパイル中」にする
    disabledButton(button);
    // submitボタンをdisabledにする
    submitButton.prop("disabled", true)
    // Ajaxを送る
    compileAjax(pdfsPath, code, pdfUrlElement, compileResultElement);
    // 結果が表示されたらボタンを元に戻す
    compileResultElement.on('DOMSubtreeModified propertychange', function(){
      replacewithNewButton(button, pdfUrlElement.val());
      submitButton.prop("disabled", false);
    });
  });
});

// 画面サイズがlg以下の時、texタブにクラスを追加削除
var mql = window.matchMedia('(max-width: 992px)');
function displayTabCopntent(e){
  if(e.matches){
    // 画面サイズが992px以下になった時の処理
    $("#tab-compile-result").attr("class", "tab-pane fade");
  }else{
    // 画面サイズが992px以上になった時の処理
    $("#tab-compile-result").attr("class", "tab-pane fade active show");
    $(".nav-tabs a[href='#tab-compile-result']").attr("class", "nav-link");
    $("#tab-tex-code").attr("class", "tab-pane fade active show");
    $(".nav-tabs a[href='#tab-tex-code']").attr("class", "nav-link active");
  }
}

mql.addEventListener("change", displayTabCopntent);

$(function(){
  if(window.innerWidth < 992){
    $("#tab-compile-result").attr("class", "tab-pane fade");
  }
});

