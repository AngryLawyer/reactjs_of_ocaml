(function (win) {

  function stripControlSequences(text) {
    return text.replace(/\x1B\[[0-9]{0,5}m/g, '');
  }

  function sliceToNextResult(resultBuffer) {
    var nextStart = -1;
    for (var i = 0; i < resultBuffer.length; ++i) {
      if (/\.\.\./.test(resultBuffer[i])) {
        nextStart = i;
        break;
      }
    }
    if (nextStart === -1) {
      return [];
    }
    return resultBuffer.slice(nextStart + 1);
  }

  function parseNextResult(karma, resultBuffer) {
    if (resultBuffer.length < 3) {
      // No more tests
      return;
    }
    // First line contains information about the test being run
    var items = resultBuffer[0].replace(/[ ]+/g, ' ').split(' ');
    var suite = [items[0]];
    var id = items[1];
    var name = items[2];

    // Next line is either empty, or an error code
    var errorLine = resultBuffer[1];
    var success = true;
    if (errorLine.indexOf('[failure]') === 0) {
      success = false;
    }

    var result = {
      description: name,
      id: id,
      log: [],
      skipped: false,
      success: success,
      suite: [suite],
      time: 0,
      executedExpectationsCount: 1
    };
    karma.result(result);
  }

  function parseResults(karma, resultBuffer) {
    console.log(resultBuffer);
    while (resultBuffer.length > 0) {
      resultBuffer = sliceToNextResult(resultBuffer);
      parseNextResult(karma, resultBuffer);
    }
  }

  function createStartFn(karma) {
    return function () {
      win.startTests();
      parseResults(karma, win.stdout_buffer.map(stripControlSequences));

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
