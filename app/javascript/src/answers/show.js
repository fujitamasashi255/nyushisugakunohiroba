import { toggleCollapseMessage } from "src/collapse"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

// 解答詳細ページ、コメント作成の折りたたみ
document.addEventListener("DOMContentLoaded", function(){
  const collapseElem = document.querySelector("#commentField");
  const collapseLink = document.querySelector("a[href='#commentField']");
  if(collapseElem){
    toggleCollapseMessage(collapseElem, collapseLink, t("javascript.comments.index.collapse.open"), t("javascript.comments.index.collapse.close"));
  }
});
