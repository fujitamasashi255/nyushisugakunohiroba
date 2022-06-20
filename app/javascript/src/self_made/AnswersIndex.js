$(function(){
  // answerカードが、スクロール後元に戻るようにする
  $(".answer-card").on("mouseleave", function(){
    $(this).scrollTop(0);
  });
});
