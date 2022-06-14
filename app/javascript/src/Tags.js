import Tagify from "@yaireo/tagify";
window.Tagify = Tagify;
import "@yaireo/tagify/dist/jQuery.tagify.min";

// 解答作成時のタグ登録
document.addEventListener("DOMContentLoaded", function(){
  var input = document.querySelector("input[name='answer[tag_list]']");
  new Tagify(input, {
    originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', ')
  });
});

