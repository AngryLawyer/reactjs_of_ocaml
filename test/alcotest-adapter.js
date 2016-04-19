(function (win) {
  
  function stripControlSequences(text) {
    return text.replace(/\x1B\[[0-9]{0,5}m/g, '');
  }

  function createStartFn(karma) {
    return function () {
      win.startTests();
      console.log(win.stdout_buffer.map(stripControlSequences).join("\n"));

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
