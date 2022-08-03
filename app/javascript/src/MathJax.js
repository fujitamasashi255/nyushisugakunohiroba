MathJax = {
  loader: {load: ['[tex]/tagformat']}, // lazy load -> 'ui/lazy',
  tex: {
    packages: {'[+]': ['tagformat', 'sections']},
    inlineMath: [ ['$','$'], ['\\(','\\)'] ],
    processEscapes: true,
    tags: 'ams',
    macros: {
      maru: ['\\enclose{circle}{#1}', 1]
    }
  },
  startup: {
    elements: [".mathjax-initialize-typeset"],
    ready() {
      const Configuration = MathJax._.input.tex.Configuration.Configuration;
      const CommandMap = MathJax._.input.tex.SymbolMap.CommandMap;
      new CommandMap('sections', {
        nextSection: 'NextSection'
      }, {
        NextSection(parser, name) {
          parser.tags.counter = parser.tags.allCounter = 0;
        }
      });
      Configuration.create(
        'sections', {handler: {macro: ['sections']}}
      );
      MathJax.startup.defaultReady();
      // タイプセットが終了したのちの処理
      MathJax.startup.promise.then(() => {
        removeBrTagsAfterDisplayMath();
      });
    }
  }
};

// ポイント、コメントプレビュー
// MathJaxによる数式表示時、ディスプレー数式の直後のbrは削除する
const removeBrTagsAfterDisplayMath = function(){
  $('mjx-container[display="true"]').next().each(function(){
    if($(this).is("br")){
      $(this).remove();
    }
  });
}

$(function(){
  // タブのプレビューを押したら
  $(document).on("click", "a.mathjax-compile-button", function(e){
    // 数式番号をリセット
    MathJax.texReset([0]);
    var tabContent = $(e.target).parents("ul.nav-tabs").next(".tab-content");
    var Code = tabContent.find("trix-editor").html();
    // 数式をタイプセット
    MathJax.typeset(tabContent.find(".mathjax-compile-result").html(Code));
    removeBrTagsAfterDisplayMath();
  });
});
