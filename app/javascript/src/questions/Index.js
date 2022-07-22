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
  if(collapseElem){
    collapseElem.addEventListener('show.bs.collapse', function(){
      let newIcon = document.createElement("i");
      newIcon.setAttribute("class", "bi bi-dash-square");
      oldIcon = collapseIconWrapper.lastChild;
      collapseIconWrapper.replaceChild(newIcon, oldIcon);
    });
    // 検索フォームの折りたたみが非表示になると、ボタンのテキストを + に変更
    collapseElem.addEventListener('hidden.bs.collapse', function(){
      let newIcon = document.createElement("i");
      newIcon.setAttribute("class", "bi bi-plus-square");
      oldIcon = collapseIconWrapper.lastChild;
      collapseIconWrapper.replaceChild(newIcon, oldIcon);
    });
  }
});

$(function(){
  // questionカードが、スクロール後元に戻るようにする
  $(document).on("mouseleave", ".question-card", function(){
    $(this).scrollTop(0);
  });
  // ページを読み込んだ際に、選択されている大学名をボタンに表示
  var checkedBoxes = $('.search-form-universities input[type="checkbox"]:checked');
  var dropDownButton = $('.search-form-universities button');
  displayCheckedUniversityNamesOnDropDownButton(checkedBoxes, dropDownButton);
  // 検索フォーム大学選択チェックボックス選択時に、選択した大学名をボタンに表示
  $('.search-form-universities input[type="checkbox"]').on('change', function(){
    var checkedBoxes = $('.search-form-universities input[type="checkbox"]:checked');
    var dropDownButton = $('.search-form-universities button');
    displayCheckedUniversityNamesOnDropDownButton(checkedBoxes, dropDownButton);
  });

  const scrollToElem = document.querySelector('.scroll-to');
  const spinner = $('<div class="spinner-border d-inline ms-4", style="width: 1.5rem; height: 1.5rem;", role="status">');
  // ajax開始前
  document.body.addEventListener("ajax:before", (event) => {
    if(event.target.classList.contains("loading")){
      // 問題一覧でのスピナー
      $(scrollToElem).append(spinner);
      scrollToElem.scrollIntoView();
      // ajax終了時
      event.target.addEventListener("ajax:success", (event) => {
        // 問題一覧でのスピナー
        const spinner = $('.scroll-to .spinner-border');
        if(spinner){
          spinner.remove();
        }
      });
    }
  });
});
