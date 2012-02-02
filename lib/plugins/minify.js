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
  
};

var css = exports.css = function(err, $, next) {
  
};