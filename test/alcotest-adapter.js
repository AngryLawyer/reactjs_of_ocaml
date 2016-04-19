(function (win) {
  function createStartFn(karma) {
    return function () {
      karma.complete({});
    };
  }

  function createDumpFn(karma, serialize) {
    return function () {
      karma.info({dump: [].slice.call(arguments) });
    };
  }

  win.__karma__.start = createStartFn(win.__karma__);
  win.dump = createDumpFn(win.__karma__, function (value) {
    return value;
  });
})(window);
