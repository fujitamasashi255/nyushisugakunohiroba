$(function(){
  $("#user-avatar-file-input").on("change", function(e){
    var file = e.target.files[0];
    // FileReaderオブジェクトreaderを作成
    const reader  = new FileReader();

		// 読み込み操作が完了するたびに以下のイベントがトリガされる。
    reader.onloadend = function () {
        const preview = $("#avatar-preview");
        if(preview) {
            preview.attr("src", reader.result);
        }
    }

		// file の Blob の内容の読み込みを開始し、終了すると、
		// result 属性にはファイルのデータを表す data: の URL が格納される。
    if (file) {
        reader.readAsDataURL(file);
    }
  });
})
