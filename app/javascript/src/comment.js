import { toggleCollapseMessage } from "src/collapse"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

document.addEventListener("DOMContentLoaded", function(){
  // 解答詳細ページ、コメント作成の折りたたみ
  const collapseElem = document.querySelector("#commentField");
  const collapseLink = document.querySelector("a[href='#commentField']");
  if(collapseElem){
    toggleCollapseMessage(collapseElem, collapseLink, t("javascript.comments.index.collapse.open"), t("javascript.comments.index.collapse.close"));
  }

  // コメントの文字数バリデーション
  // コメントフォームのラッパーを取得
  const commentField = document.getElementById("commentField");
  commentField.addEventListener("trix-change", function(e) {
    if (e.target && e.target.id == 'comment_body') {
      const { editor } = e.target;
      // エディターの文字列を取得
      const string = editor.getDocument().toString();
      // エディターの文字列の文字数を取得
      const characterCount = string.replace(/\n/g, "").length;
      // 行数
      //const newLineCount = string.match(/\r\n|\n/g).length;
      // 「コメントする」ボタンを取得
      var commentSubmitButton = document.querySelector("#comment-form-field input[type='submit']");
      // 0 < コメント数 <= 500 のとき「コメントする」ボタンを押せるようにする
      if(0 < characterCount &&  characterCount <= 500){
        commentSubmitButton.disabled = false;
      } else {
        // それ以外のとき「コメントする」ボタンを押せないようにする
        commentSubmitButton.disabled = true;
      }
    }
  });
});
