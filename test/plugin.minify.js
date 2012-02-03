/*
  Tests for the minify plugin
*/

var thimble = require('../'),
    fixtures = __dirname + '/fixtures';

describe ('plugin', function() {
  
  var options = {
    root : fixtures,
    source : 'minify.html'
  };
  
  beforeEach(function(done) {
    thimble = thimble.create(options);
    thimble.use(thimble.minify());
    done();
  });
  
  describe('.minify', function() {
    
    it('should minify css', function(done) {
      
      thimble.render('minify.html', {}, function(err, content) {
        if(err) return done(err);
        console.log(content);
        done();
      });
      
    });
    
    
  });
});
