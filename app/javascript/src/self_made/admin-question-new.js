var replaceDepartmentCheckBoxes = function(departmentCheckBoxGroup, departmentsData){
  departmentCheckBoxGroup.children('div').remove();
  $.each(departmentsData, function(){
    var span = $('<div>', {class: 'form-check-inline'}).appendTo(departmentCheckBoxGroup);
    span.append($('<input>', {type: 'checkbox', value: `${this.id}`, name:'question[department_ids][]', id: `question_department_ids_${this.id}`, class: 'form-check-input'}))
      .append($('<label>', {class: 'collection_check_boxes form-check-label', for: `question_department_ids_${this.id}`, text: this.name}));
  });
}

$(function(){
  $('.university-radio-buttons input[type="radio"]').on("click", function(){
    $('.university-radio-buttons .university-name').text(this.value);
    var departmentsPath = this.dataset.departmentsPath;
    var departmentCheckBoxGroup = $('.department-check-box-group')
    if(departmentsPath != null & departmentsPath != undefined){
      $.getJSON(departmentsPath).done(function(data, statusText, jqXHR){
        replaceDepartmentCheckBoxes(departmentCheckBoxGroup, data);
        console.log(data)
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
