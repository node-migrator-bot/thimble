
var expect = require("expect.js"),
    thimble = require('../'),
    fixtures = __dirname + '/fixtures';


var options = {
  root: fixtures
};

describe('middleware', function() {
  var middleware = null;

  beforeEach(function(done) {
    thimble = thimble.create(options);
    middleware = thimble.middleware();
    return done();
  });
  
  describe('.middleware', function() {});
});