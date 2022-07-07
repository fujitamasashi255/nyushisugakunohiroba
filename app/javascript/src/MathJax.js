MathJax = {
  loader: {load: ['[tex]/tagformat']}, // lazy load -> 'ui/lazy',
  section: 0,
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
    elements: [".point-container, .point-field"],
    ready() {
      const Configuration = MathJax._.input.tex.Configuration.Configuration;
      const CommandMap = MathJax._.input.tex.SymbolMap.CommandMap;
      new CommandMap('sections', {
        nextSection: 'NextSection'
      }, {
        NextSection(parser, name) {
          MathJax.config.section++;
          parser.tags.counter = parser.tags.allCounter = 0;
        }
      });
      Configuration.create(
        'sections', {handler: {macro: ['sections']}}
      );
      MathJax.startup.defaultReady();
      MathJax.startup.input[0].preFilters.add(({math}) => {
        if (math.inputData.recompile) MathJax.config.section = math.inputData.recompile.section;
      });
      MathJax.startup.input[0].postFilters.add(({math}) => {
        if (math.inputData.recompile) math.inputData.recompile.section = MathJax.config.section;
      });
    }
  }
};

