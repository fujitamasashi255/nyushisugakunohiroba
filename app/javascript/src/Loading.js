$(function(){
  const scrollToElem = document.querySelector('.scroll-to');
  const spinnerWrapper = $('<div class="d-flex justify-content-center align-items-center", style="height: 10rem;"></div>')
  const spinner = $('<div class="spinner-border", style="width: 1.5rem; height: 1.5rem;", role="status">');
  spinnerWrapper.append(spinner);
  // ajax開始前
  document.body.addEventListener("ajax:before", (event) => {
    if(event.target.classList.contains("loading")){
      $(".loaded").html(spinnerWrapper);
      // スピナー
      scrollToElem.scrollIntoView();

    }
  });
});

/*
タイトル横にスピナーを表示する場合
$(function(){
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
*/
