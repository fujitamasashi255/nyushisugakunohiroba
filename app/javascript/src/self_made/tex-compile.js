// called from views/texes/_form

// pdfUrlのファイルをrenderElementに表示する
var renderPdf = function(pdfUrl, renderElement){
  $('<iframe>', {type: "application/pdf", height: "500", width: "100%", marginwidth: "0"}).attr('src', pdfUrl).appendTo(renderElement);
}

// logTextをrenderElementに表示する
var renderLogText = function(logText, renderElement){
  renderElement.html(logText);
}


$(function(){
  $('#compile').on('click', function(){
    // コンパイルするコントローラへのパス Path
    var Path = this.dataset.compilePath;
    // コンパイルするtexコード compileResultElement
    var Code = $('#tex-code').val();
    // コンパイル結果を表示する要素 compileResultElement
    var compileResultElement = $('#compile-result');
    // compileResultElement を空にする
    compileResultElement.empty();
    // compile_controllerへパラメータcodeを持つリクエスト
    $.post(Path, {code: Code}, null, "json").done(function(data, statusText, jqXHR){
      // t.input_field :pdf_blob_signed_id に コンパイル結果のBlobオブジェクトのsigned_idを設定
      $('#pdf_blob_signed_id').val(data.signed_id);
      if(data.signed_id == null){
        // コンパイル失敗時
        // 帰ってくるデータ data = json: {log_text: @e.log, signed_id: nil}
        // ログのテキスト logText
        var logText = data.log_text;
        // logTextをcompileResultElementに表示する
        renderLogText(logText, compileResultElement);
      }else{
        // コンパイル成功時
        // 帰ってくるデータ data = json: {url: url_for(blob), signed_id: blob.signed_id}
        // コンパイル結果のpdfのurl
        var pdfUrl = data.url;
        // コンパイルを表示する要素 compileResultElement を取得
        // コンパイル結果を表示する
        renderPdf(pdfUrl, compileResultElement);}
    }).fail(function(jqXHR, statusText, error){
      console.error("Error");
      console.log(`jqXHR: ${jqXHR.status}`);
      console.log(`textStatus: ${textStatus}`);
      console.log(`error: ${error}`);
    });
  });
});
