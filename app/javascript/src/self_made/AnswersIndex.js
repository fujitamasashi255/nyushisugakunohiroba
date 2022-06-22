$(function(){
  // answerカードが、スクロール後元に戻るようにする
  $(document).on("mouseleave", ".answer-card", function(){
    $(this).scrollTop(0);
  });
});
