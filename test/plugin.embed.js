/*
  Tests for the embed plugin
*/

var thimble = require('../');

describe('plugin', function() {
  describe('.embed', function() {

    var options = {
      source: 'test.html',
      root: __dirname + '/fixtures/'
    };

    beforeEach(function(done) {
      thimble = thimble.create(options);
      thimble.use(thimble.embed({
        json: 'testdata'
      }));

      done();
    });

    it('should precompile hogan templates', function(done) {
      var str = "<script type = 'text/template' src = '/template.mu'>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain("Hogan.Template.prototype");
        expect(content).to.contain("window.JST['template']");
        expect(content).to.contain('_.f("planet"');

        done();
      });
    });

    it('should ignore scripts that arent templates', function(done) {
      var str = "<script type = 'text/javascript' src = '/template.mu'>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('src = "/template.mu"');

        expect(content).to.not.contain("Hogan.Template.prototype");
        expect(content).to.not.contain("window.JST['template']");

        done();
      });
    });
    it('should skip templates that it doesnt understand', function(done) {
      var str = '<script type = "text/template" src = "/template.newb">';

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain('src = "/template.newb"');

        expect(content).to.not.contain("Hogan.Template.prototype");
        expect(content).to.not.contain("window.JST['template']");

        done();
      });
    });

    it('should work when both client and server using same templating', function(done) {
      var str = "<script type = 'text/template' src = '/template.mu'>",
          locals = { lulcatz : 'herro' };

      // Set test.mu as the source file
      thimble.set('source', 'test.mu');

      thimble.eval(str, locals, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain("Hogan.Template.prototype");
        expect(content).to.contain("window.JST['template']");
        expect(content).to.contain('_.f("planet"');

        done();
      });
    });

    it('should work with json strings', function(done) {
      var str = "<script type = 'text/template' id = 'package' src = '/testdata.json'>";

      thimble.eval(str, function(err, content) {
        if(err) return done(err);

        expect(content).to.contain("window.testdata['package']");
        expect(content).to.contain("JSON.parse(");
        expect(content).to.contain("oh herro");

        done();
      });
    });

  });
});