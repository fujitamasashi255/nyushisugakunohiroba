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
$(function(){
  // 検索フォームの折りたたみが表示されると、ボタンのテキストを - に変更
  $('#collapse-search-form').on('show.bs.collapse', function(){
    $(".search-form .toggle-btn").text("ー");
  });

  // 検索フォームの折りたたみが非表示になると、ボタンのテキストを + に変更
  $('#collapse-search-form').on('hide.bs.collapse', function(){
    $(".search-form .toggle-btn").text("＋");
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
