MathJax = {
  options: {
    skipHtmlTags: {'[+]': ['trix-editor']}
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
