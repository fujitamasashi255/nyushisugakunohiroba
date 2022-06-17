import Tagify from "@yaireo/tagify";
window.Tagify = Tagify;
import "@yaireo/tagify/dist/jQuery.tagify.min";

var tags = gon.tag_suggestions

// 解答作成時のタグ登録
document.addEventListener("DOMContentLoaded", function(){
  console.log(tags);
  var input = document.querySelector("input[name='answer[tag_list]']"),
    tagify = new Tagify(input, {
      originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', '),
      whitelist : tags,
      dropdown : {
        classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
        enabled: 0,             // <- show suggestions on focus
        closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
      },
      templates: {
        dropdownHeader(suggestions){
          console.log(suggestions);
          return '<header class="p-2">あなたが同じ分野の問題につけたタグの一覧</header>';
        },
      }
    });
})
