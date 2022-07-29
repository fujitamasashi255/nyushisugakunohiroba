export const toggleCollapseMessage = function(collapseElem, collapseLink, openMessage, closeMessage){
  // 折りたたみが閉じる直前のイベント
  collapseElem.addEventListener("hide.bs.collapse", function(){
    collapseLink.innerHTML = "";
    var Icon = document.createElement("i");
    Icon.setAttribute("class", "bi bi-chevron-down ms-2");
    collapseLink.textContent = openMessage;
    collapseLink.append(Icon);
  });
  // 折りたたみが開く直前のイベント
  collapseElem.addEventListener("show.bs.collapse", function(){
    collapseLink.innerHTML = "";
    var Icon = document.createElement("i");
    Icon.setAttribute("class", "bi bi-chevron-up ms-2");
    collapseLink.textContent = closeMessage;
    collapseLink.append(Icon);
  });
}
