/*
  layout.js - Plugin to allow layouts to be given, enables the <yield /> tag
*/

/*
  Module dependencies
*/

var fs = require('fs'),
    path = require('path'),
    join = path.join,
    extname = path.extname,
    _ = require('underscore'),
    cheerio = require('cheerio'),
    thimble = require('../thimble'),
    utils = require('../utils'),
    after = utils.after,
    read = utils.read,
    step = utils.step;
    
/*
  Export module
*/

exports = module.exports = function(opts) {
  return function (content, options, fn) {
    if(!options.layout) return fn(null, content);

    // Convert all string to an array
    if(typeof options.layout === 'string')
      options.layout = [options.layout];

    // Prepare the step chain
    var begin = function(next) {
      return next(null, options);
    };

    step(begin, readAll, compose, function(err, layout) {
      if(err) return fn(err);

      var $ = cheerio.load(layout);
      $('yield').replaceWith(content);

      return fn(null, $.html());
    });
  };
};

var readAll = exports.readAll = function(err, options, next) {
  if(err) return next(err);
  var layouts = options.layout,
      finished = after(layouts.length),
      out = [],
      root = options.root;

  // Run through the layouts
  _.each(layouts, function(layout, i) {
    layout = join(root, layout);

    // Read the layout
    read(layout, function(err, str) {
      if(err) return next(err);

      // Compile the layout
      thimble.compile(layout, options.locals)(str, options, function(err, html) {
        if(err) return next(err);

        // Fix the path
        thimble.path(layout)(html, options, function(err, html) {
          if(err) return next(err);

          // Add to output at correct spot
          out[i] = html;

          // If we've run through all the layouts, return
          if(finished())
            return next(null, out);
        });
      });
    });
  });
};

var compose = exports.compose = function(err, layouts, next) {
  if(err) return next(err);
  var $ = cheerio.load(layouts.shift()),
      finished = after(layouts.length);

  _.each(layouts, function(html) {
    $('yield').replaceWith(html);
    $ = cheerio.load($.html());
  });

  return next(null, $.html());
};

