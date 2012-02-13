/*
  Path.js plugin corrects thimble's paths
*/

var utils = require('../utils'),
    relative = utils.relative,
    path = require('path'),
    dirname = path.dirname,
    join = path.join,
    cheerio = require('cheerio');

// Tags
var assets = 'script, link, img'

exports = module.exports = function(rel, opts) {
  opts = opts || {};
  
  return function(content, options, next) {
    var root = options.root,
        source = rel || options.source,
        env = options.env,
        $ = cheerio.load(content);
    
    // Source directory
    var directory = dirname(source);
    
    $(assets).each(function() {
      var attr = (this.tag === 'link') ? 'href' : 'src',
          $this = $(this);
      
      path = $this.attr(attr);
      
      if(!path || path[0] === '/' || ~path.indexOf('http'))
        return;

      // Full path from source directory
      path = join(directory, path);
      
      // Make relative to root
      path = relative(root, path);
      
      // Prepend '/'
      path = join('/', path);
            
      $this.attr(attr, path);
      
    });

    next(null, $.html());
  };
}