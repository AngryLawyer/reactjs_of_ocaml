var path = require('path');

var createPattern = function (pattern) {
  return {pattern: pattern, included: true, served: true, watched: false};
};

var init = function (files) {
  files.unshift(createPattern(path.join(__dirname, '/alcotest-adapter.js')));
};

init.$inject = ['config.files'];

module.exports = {
  'framework:alcotest-adapter': ['factory', init]
};
