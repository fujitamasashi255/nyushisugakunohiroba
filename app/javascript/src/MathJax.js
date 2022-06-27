MathJax = {
  options: {
    skipHtmlTags: {'[+]': ['trix-editor', 'tag']},
    ignoreHtmlClass: 'tagify__input|tag'
  },
  tex: {
    packages: {'[+]': ['tagformat']},
    inlineMath: [ ['$','$'], ['\\(','\\)'] ],
    processEscapes: true,
    tags: 'ams',
    macros: {
      maru: ['\\enclose{circle}{#1}', 1]
    }
  }
}
