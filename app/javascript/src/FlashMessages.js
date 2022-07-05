$(function(){
  var flashElem = $(".flash-messages .alert-success");
  if(flashElem.length > 0){
    setTimeout(function(){
      flashElem.fadeTo(4000, 0);
    }, 2000);
  }
});
