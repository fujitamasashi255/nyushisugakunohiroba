// called from views/admin/questions/new, edit

// チェックボックスの内容を置き換えるメソッド
var replaceDepartmentCheckBoxes = function(departmentCheckBoxGroup, departmentsData){
  departmentCheckBoxGroup.children('div').remove();
  $.each(departmentsData, function(){
    var span = $('<div>', {class: 'form-check-inline'}).appendTo(departmentCheckBoxGroup);
    span.append($('<input>', {type: 'checkbox', value: `${this.id}`, name:'question[department_ids][]', id: `question_department_ids_${this.id}`, class: 'form-check-input'}))
      .append($('<label>', {class: 'collection_check_boxes form-check-label', for: `question_department_ids_${this.id}`, text: this.name}));
  });
}

$(function(){
  // 大学選択のラジオボタンが押されたら
  $('.university-radio-buttons input[type="radio"]').on("click", function(){
    // ラジオボタンで押した大学名をボタンに表示する
    $('.university-radio-buttons .university-name').text(this.value);
    // 押したラジオボタンの大学の区分を取得するアクションのパス departmentsPath
    var departmentsPath = this.dataset.departmentsPath;
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
});
