var displayCheckedUniversityNamesOnDropDownButton = function(checkedBoxes, dropDownButton){
  // 選択した大学の名前を格納する配列
  var universityNames = [];
  checkedBoxes.each(function(){
    var checkBoxDropdownItem = $(this).parent();
    universityNames.push(checkBoxDropdownItem.text());
  });
  dropDownButton.text(universityNames.join("、"));
}


// 検索フォーム折りたたみ
document.addEventListener('DOMContentLoaded', function(){
  let collapseElem = document.querySelector('#collapse-search-form');
  let collapseIconWrapper = document.querySelector('.search-form-icon');
  // 検索フォームの折りたたみが表示されると、ボタンのテキストを - に変更
  collapseElem.addEventListener('show.bs.collapse', function(){
    collapseIconWrapper.innerHTML = "";
    let Icon = document.createElement("i");
    Icon.setAttribute("class", "bi bi-dash-square toggle-btn");
    Icon.setAttribute("data-bs-toggle", "collapse");
    Icon.setAttribute("href", "#collapse-search-form");
    Icon.setAttribute("role", "button");
    collapseIconWrapper.append(Icon);
  });
  // 検索フォームの折りたたみが非表示になると、ボタンのテキストを + に変更
  collapseElem.addEventListener('hide.bs.collapse', function(){
    collapseIconWrapper.innerHTML = "";
    let Icon = document.createElement("i");
    Icon.setAttribute("class", "bi bi-plus-square toggle-btn");
    Icon.setAttribute("data-bs-toggle", "collapse");
    Icon.setAttribute("href", "#collapse-search-form");
    Icon.setAttribute("role", "button");
    collapseIconWrapper.append(Icon);
  });
});


// 検索フォーム大学選択チェックボックスでドロップダウンが閉じた時に
// 選択した大学名をボタンに表示
$(function(){
  $('.search-form-universities input[type="checkbox"]').on('change', function(){
    var checkedBoxes = $('.search-form-universities input[type="checkbox"]:checked');
    var dropDownButton = $('.search-form-universities button');
    displayCheckedUniversityNamesOnDropDownButton(checkedBoxes, dropDownButton);
  });
});
