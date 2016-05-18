(function (win) {

  function stripControlSequences(text) {
    return text.replace(/\x1B\[[0-9]{0,5}m/g, '');
  }

  function findNextIndex(array, callback) {
    var nextStart = -1;
    for (var i = 0; i < array.length; ++i) {
      if (callback(array[i])) {
        nextStart = i;
        break;
      }
    }
    return nextStart;
  }

  function sliceToNextResult(resultBuffer) {
    var nextStart = findNextIndex(resultBuffer, function (line) {
      return (/\.\.\./.test(line));
    });

    if (nextStart === -1) {
      return [];
    }
    return resultBuffer.slice(nextStart + 1);
  }

  function parseNextResult(resultBuffer) {
    if (resultBuffer.length < 3) {
      // No more tests
      return;
    }
    // First line contains information about the test being run
    var items = resultBuffer[0].replace(/[ ]+/g, ' ').split(' ');
    var suite = [items[0]];
    var id = items[1];
    var name = items[2];

    // Find an error line
    var lineIdx = 1;
    while (lineIdx < resultBuffer.length) {
      var errorLine = resultBuffer[lineIdx];
      var success = true;
      var errorText = [];
      if (errorLine.indexOf('[failure]') === 0) {
        success = false;
        var errorsEnd = findNextIndex(resultBuffer, function (line) {
          return (/^\[ERROR\]/.test(line));
        });
        errorText = resultBuffer.slice(1, errorsEnd).filter(function (item) { return item.trim(); });
        break;
      }
      if (/\.\.\./.test(errorLine)) {
        break;
      }
      lineIdx += 1;
    }

    var result = {
      description: name,
      id: id,
      log: errorText,
      skipped: false,
      success: success,
      suite: [suite],
      time: 0,
      executedExpectationsCount: 1
    };
    return result;
  }

  function parseResults(karma, resultBuffer) {
    var resultList = [];
    while (resultBuffer.length > 0) {
      resultBuffer = sliceToNextResult(resultBuffer);
      resultList.push(parseNextResult(resultBuffer));
    }
    resultList = resultList.filter(function (x) { return x; });
    karma.info({
      total: resultList.length
    });
    resultList.forEach(function (result) {
      karma.result(result);
    });
  }

  function createStartFn(karma) {
    return function () {
      win.startTests();
      parseResults(karma, win.stdout_buffer.map(stripControlSequences).join("\n").split("\n"));

      karma.complete({});
    };
  }

  function createDumpFn(karma) {
    return function () {
      karma.info({dump: [].slice.call(arguments) });
    };
  }

  win.__karma__.start = createStartFn(win.__karma__);
  win.dump = createDumpFn(win.__karma__, function (value) {
    return value;
  });
})(window);
