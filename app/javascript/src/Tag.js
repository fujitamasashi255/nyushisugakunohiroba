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
  whitelist : [],
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
  var startYearSelect = document.querySelector("select[name = 'questions_search_form[start_year]']");
  var endYearSelect = document.querySelector("select[name = 'questions_search_form[end_year]']");
  var universityIdInputs = document.querySelectorAll("input[name = 'questions_search_form[university_ids][]']");
  var unitIdInputs = document.querySelectorAll("input[name = 'questions_search_form[unit_ids][]']");
  var tagInput = document.querySelector("input[id = 'question-tag-input']");

  if(tagInput){
    var tagify = new Tagify(tagInput, searchSettings);
    var controller;

    // listen to any keystrokes which modify tagify's input
    tagify.on('focus', onFocus)

    function onFocus( e ){
      var universityIds = []
      var unitIds = []
      var startYear = startYearSelect.value
      var endYear = endYearSelect.value

      for(var i=0; i < universityIdInputs.length; i++){
        if(universityIdInputs[i].checked){
          universityIds.push(universityIdInputs[i].value);
        }
      }
      for(var i=0; i < unitIdInputs.length; i++){
        if(unitIdInputs[i].checked){
          unitIds.push(unitIdInputs[i].value);
        }
      }

      console.log(startYear);
      console.log(endYear);
      console.log(unitIds);
      console.log(universityIds);

      tagify.whitelist = null // reset the whitelist

      // https://developer.mozilla.org/en-US/docs/Web/API/AbortController/abort
      controller && controller.abort()
      controller = new AbortController()

      // show loading animation and hide the suggestions dropdown
      tagify.loading(true).dropdown.hide()

      fetch('http://get_suggestions.com?value=' + value, {signal:controller.signal})
        .then(RES => RES.json())
        .then(function(newWhitelist){
          tagify.whitelist = newWhitelist // update whitelist Array in-place
          tagify.loading(false).dropdown.show(value) // render the suggestions dropdown
        })
    }
  }
});

