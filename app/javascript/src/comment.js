import { toggleCollapseMessage } from "src/collapse"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

const CommentMaxLength = 1000;
const CommentMinLength = 1;

document.addEventListener("DOMContentLoaded", function(){
  // 解答詳細ページ、コメント作成の折りたたみ
  const collapseElem = document.querySelector("#commentField");
  const collapseLink = document.querySelector("a[href='#commentField']");
  if(collapseElem){
    toggleCollapseMessage(collapseElem, collapseLink, t("javascript.comments.index.collapse.open"), t("javascript.comments.index.collapse.close"));
  }

  // コメントの文字数バリデーション
  // コメントフォームのラッパーを取得
  const commentContainer = document.getElementById("comments-container");
  if(commentContainer){
    commentContainer.addEventListener("trix-change", function(e) {
      if (e.target && e.target.id == 'comment_body') {
        const { editor } = e.target;
        // エディターの文字列を取得
        const string = editor.getDocument().toString();
        // エディターの文字列の文字数を取得
        const characterCount = string.replace(/\n/g, "").length;
        // 行数
        //const newLineCount = string.match(/\r\n|\n/g).length;
        // 「コメントする」ボタンを取得
        var commentSubmitButton = $(e.target).parents(".comment-form-field").find("input[type='submit']");
        // CommentMinLength <= コメント数 <= CommentMaxLength のとき「コメントする」ボタンを押せるようにする
        if(CommentMinLength <= characterCount &&  characterCount <= CommentMaxLength){
          commentSubmitButton.prop("disabled", false);
        } else {
          // それ以外のとき「コメントする」ボタンを押せないようにする
          commentSubmitButton.prop("disabled", true);
        }
      }
    });
  }
});


// コメントの無限スクロールページネーション
var loadNextPage = function(){
  if ($('#next_link').length == 0 || $('#next_link').data("loading")){ return }  // prevent multiple loading
  var wBottom  = $(window).scrollTop() + $(window).height();
  var elBottom = $('#comments').offset().top + $('#comments').height();
  if (wBottom > elBottom){
    $('#next_link')[0].click();
    $('#next_link').data("loading", true);
  }
};

window.addEventListener('resize', loadNextPage);
window.addEventListener('scroll', loadNextPage);
window.addEventListener('load',   loadNextPage);
