/*
  Tests for the flatten plugin
*/
var thimble = require('../'),
    expect = require('expect.js'),
    fixtures = __dirname + '/fixtures';

describe('plugin', function() {
  describe('.flatten', function() {

    var options = {
      root: fixtures,
      source: fixtures + '/index.html'
    };

    beforeEach(function(done) {
      thimble = thimble.create(options);
      thimble.use(thimble.flatten());

      done();
    });

    it('should include relative files', function(done) {
      var str = "<h2><include src = 'title.html' /></h2>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('This is a pretty important title');

        done();
      });
    });

    it('should include absolute files', function(done) {
      var str = "<h2><include src = '/title.html' /></h2>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('This is a pretty important title');

        done();
      });
    });

    it('should work with plugins', function(done) {
      var str = "<h2><include src = 'post.jade' /></h2>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('<p>this is a post</p>');

        done();
      });
    });

    it('should load index.html when a directory is given', function(done) {
      var str = "<h2><include src = '/' /></h2>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('cool story, man');

        done();
      });
    });

  });
});