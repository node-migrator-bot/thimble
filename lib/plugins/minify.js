/*
  minify.js - Minifies js, css, and html
*/

/*
  Module dependencies
*/

var cheerio = require('cheerio'),
    thimble = require('../thimble'),
    utils = thimble.utils,
    step = utils.step;

/*
  Exports
*/
exports = module.exports = function(opts) {
  
  return function(content, options, next) {

    function before(next) {
      var $ = cheerio.load(content);
      next(null, $);
    }
    
    function after(err, $) {
      next(err, $.html());
    }
    
    step(before, css, js, after);
    
  };
};

var js = exports.js = function(err, $, next) {
  var uglify = require('uglify-js'),
      parser = uglify.parser,
      $script = $('script'),
      str = $script.text(),
      ast;
  
  uglify = uglify.uglify;
  
  ast = parser.parse(str);
  ast = uglify.ast_mangle(ast);
  ast = uglify.ast_squeeze(ast);
  
  $script.text(uglify.gen_code(ast));
  
  next(null, $);
};

var css = exports.css = function(err, $, next) {
  var compressor = require('clean-css'),
      $style = $('style'),
      str = $style.text();
      
  $style.text(compressor.process(str));
  
  next(null, $);
};