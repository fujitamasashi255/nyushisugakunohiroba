// called from views/admin/questions/new, edit

import { t } from "../../packs/admin";

// 関数を定義

// 区分チェックボックスの内容を置き換えるメソッド
var replaceDepartmentCheckBoxes = function(departmentCheckBoxGroup, departmentsData){
  departmentCheckBoxGroup.children('div').remove();
  $.each(departmentsData, function(){
    var wrapper = $('<div>', { class: `form-inline mb-3 department${this.id}-question-number-group` }).appendTo(departmentCheckBoxGroup);
    var radioButton = $('<div>', {class: 'form-check'}).appendTo(wrapper);
    radioButton.append($('<input>', {type: 'checkbox', value: `${this.id}`, name:'question[department_ids][]', id: `question_department_ids_${this.id}`, class: 'form-check-input'}))
      .append($('<label>', {class: 'form-check-label py-3', for: `question_department_ids_${this.id}`, text: this.name}));
  });
}

// チェックされたチェックボックスの横に問題番号セレクトボックスを挿入する
var insertSelectBox = function(checked_id, insertElement){
  var selectWrapper = $('<div>', {class: "form-group question-number-selectbox"});
  var selectLabel = $('<label>', {text: t("activerecord.attributes.questions_departments_mediator.question_number"), class: "string optional ml-4 col-form-label", for: `question_department_questions_departments_mediator__${checked_id}_question_number`});
  var selectBox = $('<select>', {class: "select optional form-control ml-2", name: `question[department[questions_departments_mediator]][${checked_id}][question_number]`, id: `question_department_questions_departments_mediator__${checked_id}_question_number`});
  for(var i=1;i<=20;i++){
    selectBox.append($('<option>', {value: i, text: i}));
  }
  insertElement.append(selectWrapper.append(selectLabel).append(selectBox));
}

// チェックされたチェックボックスの横にセレクトボックスがあればそれを削除する
var deleteSelectBox = function(parentElement){
  parentElement.find('.question-number-selectbox').remove();
}


// 大学選択時のイベント
$(function(){
  // 大学選択のラジオボタンが押されたら
  $('.university-radio-buttons input[type="radio"]').on("click", function(){
    // 押されたラジオボタンのラベル名を取得
    var univName = $(this).next().text();
    // ラジオボタンで押した大学名をボタンに表示する
    $('.university-radio-buttons .dropdown-button').text(univName);
    // 押したラジオボタンの大学の区分を取得するアクションのパス departmentsPath
    var departmentsPath = $(this).data().departmentsPath;
    // 区分を表示する要素 departmentCheckBoxGroup
    var departmentCheckBoxGroup = $('.department-check-box-group')
    if(departmentsPath != null & departmentsPath != undefined){
      // department_check_boxes_controllerへリクエスト
      // data = json: university.departments.select(:id, :name)
      $.getJSON(departmentsPath).done(function(data, statusText, jqXHR){
        replaceDepartmentCheckBoxes(departmentCheckBoxGroup, data);
      }).fail(function(jqXHR, statusText, error){
        console.error("Error occurred in replaceChildrenOptions");
        console.log(`jqXHR: ${jqXHR.status}`);
        console.log(`textStatus: ${textStatus}`);
        console.log(`error: ${error}`);
      });
    }else{
      replaceDepartmentCheckBoxes(departmentCheckBoxGroup, []);
    }
  });

  // 区分のチェックボックスのチェックが変わったときのイベント
  $(document).on('change', '.department-check-box-group input[type="checkbox"]', function(){
    var unCheckedBoxes = $('.department-check-box-group input[type="checkbox"]:not(:checked)');
    unCheckedBoxes.each(function(){
      var value = $(this).val();
      deleteSelectBox($(this).parents(`.department${value}-question-number-group`));
    });

    var checkedBoxes = $('.department-check-box-group input[type="checkbox"]:checked');
    checkedBoxes.each(function(){
      var value = $(this).val();
      insertSelectBox(value, $(this).parents(`.department${value}-question-number-group:not(:has(select))`));
    });
  });
});
