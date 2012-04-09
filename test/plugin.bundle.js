/*
  Tests for the bundle plugin
*/
var fs = require('fs'),
    expect = require('expect.js'),
    cheerio = require('cheerio'),
    fixtures = __dirname + '/fixtures',
    thimble = require('../');


describe('plugin', function() {

  describe('.bundle', function() {
    var options = {
      root: fixtures
    };

    beforeEach(function(done) {
      thimble = thimble.create(options);
      thimble.use(thimble.bundle());

      done();
    });

    it('should merge two inline scripts', function(done) {
      var html = "<script type = \"text/javascript\">alert('one');</script>\n<script type = \"text/javascript\">alert('two');</script>\n<body></body>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content);

        // Check to see if there is only one script tag
        expect($('script').length).to.be(1);
        expect($('body').find('script').length).to.be(1);

        done();
      });
    });

    it('should merge two inline styles', function(done) {
      var html = "<head></head>\n<style type = \"text/css\">h1 { background-color : red }</style>\n<style type = \"text/css\">h2 { background-color : blue }</style>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content);

        // Check to see if there is only one style tag
        expect($('style').length).to.be(1);
        expect($('head').find('style').length).to.be(1);

        done();
      });
    });

    it('should bring in external scripts', function(done) {
      var html = "<head></head>\n<script type = \"text/template\" src = \"/script.js\"></script>\n<script type = \"text/javascript\" src = \"/script.js\"></script>\n<link type = \"text/css\" href = \"/style.css\" />\n<body></body>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content),
            script = $('script[type="text/javascript"]'),
            templates = $('script[type="text/template"]'),
            link = $('link'),
            style = $('style');

        // Gets all the scripts of type text/javascript
        expect(script.length).to.be(1);
        expect($('body').find('script[type="text/javascript"]').length).to.be(1);

        // Checks to make sure rest of templates are text/template
        expect($('script[src]').length - templates.length).to.be(0);

        // No more link tags
        expect(link.length).to.be(0);

        // Only style tags
        expect(style.length).to.be(1);
        expect($('head').find('style').length).to.be(1);

        done();
      });
    });

    it('should compile assets like stylus and coffeescript', function(done) {
      var html = "<head></head>\n<script type = \"text/javascript\" src = \"/cool.coffee\"></script>\n<link type = \"text/css\" href = \"/style.styl\" />\n<body></body>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content);

        // Should compile files
        expect($('script').text()).to.contain('console.log("cool");');
        expect($('style').text()).to.contain('color: #999;');

        done();
      });
    });

    it('should maintain proper order', function(done) {
      var html = "<head></head>\n<script type = \"text/javascript\" src = \"/cool.coffee\"></script>\n<script type = \"text/javascript\">alert(\"hi world\");</script>\n<link type = \"text/css\" href = \"/style.styl\" />\n<style type = \"text/css\">h1 { background-color : red; }</style>\n<body></body>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content),
            script = $('script').text(),
            style = $('style').text(),
            str1 = script.indexOf('console.log("cool");'),
            str2 = script.indexOf('alert("hi world");');

        // Make sure these strings exist
        expect(str1 >= 0).to.be(true);
        expect(str2 >= 0).to.be(true);

        // Make sure they are in proper order
        expect(str1 < str2).to.be(true);

        // Now for the css
        str1 = style.indexOf('color: #999;');
        str2 = style.indexOf('h1 { background-color : red; }');

        // Make sure these strings exist
        expect(str1 >= 0).to.be(true);
        expect(str2 >= 0).to.be(true);

        // Make sure they are in proper order
        expect(str1 < str2).to.be(true);

        done();
      });
    });

    it('should ignore http://', function(done) {
      var html = "<head></head>\n<script type = \"text/javascript\" src = \"http://code.jquery.com/jquery-1.7.1.min.js\"></script>\n<link type = \"text/css\" href = \"http://yui.yahooapis.com/3.4.1/build/cssreset/cssreset-min.css\" />\n<body></body>";

      thimble.eval(html, function(err, content) {
        if(err) return done(err);
        var $ = cheerio.load(content);

        // Don't mess with script and link tags that have http sources
        expect($('script[src]').length).to.be(1);
        expect($('link').length).to.be(1);

        done();
      });
    });
  });
});