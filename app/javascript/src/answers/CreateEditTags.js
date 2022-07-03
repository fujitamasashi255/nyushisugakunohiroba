import Tagify from "@yaireo/tagify";
window.Tagify = Tagify;
import "@yaireo/tagify/dist/jQuery.tagify.min";

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

// 解答作成時のtag一覧
var user_answers_tags = gon.tags


//解答作成時のtagifyの設定
const settings = {
  originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', '),
  whitelist : user_answers_tags,
  dropdown : {
    classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
    enabled: 0,             // <- show suggestions on focus
    closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
  },
  templates: {
    dropdownHeader(suggestions){
      return `<header class="p-2">${t("javascript.tag.hint")}</header>`;
    },
    dropdownItem( item, tagify ){
      return `<div ${this.getAttributes(item)}
                  class='${this.settings.classNames.dropdownItem} ${item.class ? item.class : ""}'
                  tabindex="0"
                  role="option">${item.value}</div>`
    },
  }
}

document.addEventListener("DOMContentLoaded", function(){
  // 解答作成、編集時
  var inputAnswer = document.querySelector("input[name='answer[tag_list]']");
  if(inputAnswer){
    new Tagify(inputAnswer, settings);
  }
});

