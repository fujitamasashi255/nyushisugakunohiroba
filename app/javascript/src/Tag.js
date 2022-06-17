import Tagify from "@yaireo/tagify";
window.Tagify = Tagify;
import "@yaireo/tagify/dist/jQuery.tagify.min";

var tags = gon.tags

const settings = {
  originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', '),
  whitelist : tags,
  dropdown : {
    classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
    enabled: 0,             // <- show suggestions on focus
    closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
  },
  templates: {
    dropdownHeader(suggestions){
      return '<header class="p-2">あなたが同じ分野の問題につけたタグの一覧</header>';
    },
    dropdownItem( item, tagify ){
      return `<div ${this.getAttributes(item)}
                  class='${this.settings.classNames.dropdownItem} ${item.class ? item.class : ""}'
                  tabindex="0"
                  role="option">${item.value}</div>`
    },
  }
}

const searchSettings = {
  originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', '),
  whitelist : ["微分積分学の基本定理", "オムニバス", 3],
  dropdown : {
    maxItems: 20,
    classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
    enabled: 0,             // <- show suggestions on focus
    closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
  },
  templates: {
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

  // 問題検索時
  var inputQuestionSearch = document.querySelector("input[id = 'question-tag-input']");
  if(inputQuestionSearch){
    new Tagify(inputQuestionSearch, searchSettings);
  }
});
