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

// 解答作成時のタグ登録
document.addEventListener("DOMContentLoaded", function(){
  var input = document.querySelector("input[name='answer[tag_list]']");
  if(input){
    new Tagify(input, settings);
  }
});
