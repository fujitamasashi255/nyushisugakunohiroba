document.addEventListener("DOMContentLoaded", function(){
  // カルーセル
  const carousel = document.querySelector('.carousel');
  if(carousel){
    const carouselObj = new bootstrap.Carousel('#carouselAnswerFiles');
    const nextButton = document.querySelector('.carousel-next');
    const prevButton = document.querySelector('.carousel-prev');
    if(nextButton){
      // ボタンを押すとスライド
      nextButton.addEventListener("click", function(){
        carouselObj.next();
      });
      prevButton.addEventListener("click", function(){
        carouselObj.prev();
      });
      // スライドするとインディケーターを変化させる
      carousel.addEventListener('slide.bs.carousel', event => {
        var nextIndicator = document.querySelectorAll('.indicator i').item(event.to);
        var currentIndicator = document.querySelectorAll('.indicator i').item(event.from);
        nextIndicator.classList.remove("bi-circle");
        nextIndicator.classList.add("bi-circle-fill");
        currentIndicator.classList.remove("bi-circle-fill");
        currentIndicator.classList.add("bi-circle");
      });
    }
  }
})
