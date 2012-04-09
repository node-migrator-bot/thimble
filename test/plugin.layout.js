/*
  Tests for the layout plugin
*/

var thimble = require('../'),
    expect = require('expect.js'),
    fixtures = __dirname + '/fixtures';

describe('plugin', function() {
  describe('.layout', function() {

    var options = {
      root: fixtures
    };

    beforeEach(function(done) {
      thimble = thimble.create(options);

      done();
    });

    it('should place content within <yield /> tag', function(done) {
      var str = 'hi there';
      options.layout = 'layout.html';

      thimble.eval(str, options, function(err, content) {
        if(err) return done(err);

        expect(content).to.equal("<html>hi there</html>");

        done();
      });
    });

    it('should chain multiple layouts', function(done) {
      var str = 'hi there';
      options.layout = ['layout.html', 'layout.html'];

      thimble.eval(str, options, function(err, content) {
        if(err) return done(err);

        expect(content).to.equal("<html><html>hi there</html></html>");

        done();
      });
    });

  });
});