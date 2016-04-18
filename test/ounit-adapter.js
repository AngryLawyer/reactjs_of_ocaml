(function (win) {
  function createStartFn(karma) {
    return function () {
    };
  }

  function createDumpFn(karma, serialize) {
    return function () {
      karma.info({dump: [].slice.call(arguments) });
    };
  }

  win.__karma__.start = createStartFn(window.__karma__);
  win.dump = createDumpFn(win.__karma__, function (value) {
    return value;
  });
})(window);
