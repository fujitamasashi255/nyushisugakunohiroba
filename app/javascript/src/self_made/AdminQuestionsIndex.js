var displayCheckedUniversityNamesOnDropDownButton = function(checkedBoxes, dropDownButton){
  // 選択した大学の名前を格納する配列
  var universityNames = [];
  checkedBoxes.each(function(){
    var checkBoxLabel = $(this).next();
    universityNames.push(checkBoxLabel.text());
  });
  dropDownButton.text(universityNames.join("、"));
}


// 検索フォーム折りたたみ
document.addEventListener('DOMContentLoaded', function(){
  let collapseElem = document.querySelector('#collapse-search-form');
  let collapseButton = document.querySelector('.search-form .toggle-btn');
  // 検索フォームの折りたたみが表示されると、ボタンのテキストを - に変更
  collapseElem.addEventListener('show.bs.collapse', function(){
    collapseButton.innerHTML = "ー";
  });
  // 検索フォームの折りたたみが非表示になると、ボタンのテキストを + に変更
  collapseElem.addEventListener('hide.bs.collapse', function(){
    collapseButton.innerHTML = "+";
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
