var thimble = require('../'),
    expect = require('expect.js');

describe('plugin', function() {
  describe('.compile', function() {
    var fixtures = __dirname + '/fixtures';

    var options = {
      root: fixtures,
      plugins: []
    };

    beforeEach(function(done) {
      thimble = thimble.create(options);
      done();
    });

    it('should compile stylus', function(done) {

      thimble.render('style.styl', function(err, content) {
        if(err) return done(err);

        // Stylus should be compiled
        expect(content).to.contain('color: #999;');

        done();
      });
    });

    it('should compile coffeescript', function(done) {

      thimble.render('cool.coffee', function(err, content) {
        if(err) return done(err);

        // Coffeescript should be compiled
        expect(content).to.contain('return console.log("cool");');

        done();
      });
    });

    it('should compile jade', function(done) {

      thimble.render('post.jade', function(err, content) {
        if(err) return done(err);

        // Jade should be compiled
        expect(content).to.contain('<p>this is a post</p>');

        done();
      });
    });

    it('should compile markdown', function(done) {

      thimble.render('markdown.md', function(err, content) {
        if(err) return done(err);

        // Markdown should be compiled
        expect(content).to.contain("<h1>Header 1</h1>");
        expect(content).to.contain("<strong>hi there</strong>");
        expect(content).to.contain("<em>cool</em>");

        done();
      });
    });

    it('should render hogan in development', function(done) {
      var locals = { planet : 'Mars' };

      thimble.render('template.mu', locals, function(err, content) {
        if(err) return done(err);

        // Mustache should be compiled
        expect(content).to.contain("hello Mars!");

        done();
      });
    });

  });
});