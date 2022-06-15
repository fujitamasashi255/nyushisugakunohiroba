require("trix");
require("@rails/actiontext");


(function() {
  addEventListener("trix-initialize", function(e) {
    const file_tools = document.querySelector(".trix-button-group--file-tools");
    file_tools.remove();
  })
  // action text のドロップダウン によるファイルattach機能を無効化
  addEventListener("trix-file-accept", function(e) {
    e.preventDefault();
  })
})();
