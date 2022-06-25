import Tagify from "@yaireo/tagify";
window.Tagify = Tagify;
import "@yaireo/tagify/dist/jQuery.tagify.min";

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

// 解答検索時のajaxのパス
const answersTagsPath = "/answers_tags"

// 解答検索時のtagifyの設定
const answersSearchSettings = {
  originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(', '),
  whitelist : [],
  dropdown : {
    classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
    enabled: 0,             // <- show suggestions on focus
    closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
  },
  templates: {
    dropdownItem( item, tagify ){
      return `<div ${this.getAttributes(item)}
                  class='${this.settings.classNames.dropdownItem} ${item.class ? item.class : ""}'
                  tabindex="0"
                  role="option">${item.value}(${item.count})</div>`
    },
  }
}

document.addEventListener("DOMContentLoaded", function(){
  // 解答検索時
  var startYearSelect = document.querySelector("select[name = 'answers_search_form[start_year]']");
  var endYearSelect = document.querySelector("select[name = 'answers_search_form[end_year]']");
  var universityIdInputs = document.querySelectorAll("input[name = 'answers_search_form[university_ids][]']");
  var unitIdInputs = document.querySelectorAll("input[name = 'answers_search_form[unit_ids][]']");
  var tagInput = document.querySelector(".answers-search-form input[id = 'tag-input']");

  if(tagInput){
    var tagify = new Tagify(tagInput, answersSearchSettings);
    var controller;

    // listen to any keystrokes which modify tagify's input
    tagify.on('focus', onFocus);

    // タグ入力フィールドがフォーカスされたら以下が実行される
    function onFocus( e ){
      // 出題年、大学、単元に指定した値を取得し、クエリパラメータを作成
      var params = new URLSearchParams();

      params.append("tags_search_form[start_year]", startYearSelect.value);
      params.append("tags_search_form[end_year]", endYearSelect.value);
      for(var i=0; i < universityIdInputs.length; i++){
        if(universityIdInputs[i].checked){
          params.append("tags_search_form[university_ids][]", universityIdInputs[i].value);
        }
      }
      for(var i=0; i < unitIdInputs.length; i++){
        if(unitIdInputs[i].checked){
          params.append("tags_search_form[unit_ids][]", unitIdInputs[i].value);
        }
      }

      tagify.whitelist = null; // reset the whitelist

      // https://developer.mozilla.org/en-US/docs/Web/API/AbortController/abort
      controller && controller.abort();
      controller = new AbortController();

      // show loading animation and hide the suggestions dropdown
      tagify.loading(true).dropdown.hide();

      // ajaxを送信して、タグを取得しsuggestionに表示する
      fetch(answersTagsPath + "/?" + params.toString(), {signal:controller.signal})
        .then(response => response.json())
        .then(function(newWhiteList){
          tagify.whitelist = newWhiteList; // update whitelist Array in-place
          tagify.loading(false).dropdown.show(); // render the suggestions dropdown
        })
    }
  }
})
