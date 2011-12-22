
###
  Load modules
###

path = require 'path'
fs = require 'fs'
should = require "should"
thimble = require '../thimble'

###
  Used to compile languages for both assets and views
###

exports = module.exports = (file) ->
  extname = path.extname(file).substring(1)
  extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname
  
  return (content, options, next) ->
    locals = options.locals || {}
    locals._thimble = options

    compiler = exports[extname]

    # Compile the file
    if compiler
      compiler file, locals, (err, str) ->
        return next(err, str)
    else
      return next(null, content)

###
  Content Cache
###

cache = {};

###
  Requires Cache
###

requires = {};

###
  Read `file` with `options` with
  callback `(err, str)`. When `options.cache`
  is true the template string will be cached.  
###

read = (file, options, fn) ->
  # Figure out why I need this "|| {}"
  options = options._thimble || {}
  str = cache[file]

  return fn(null, str) if options.cache and str
  fs.readFile file, "utf8", (err, str) ->
    return fn(err)  if err
    cache[file] = str  if options.cache
    fn null, str

###
  Private extensions to types map
###

types = 
  'coffeescript' : 'js'
  'stylus' : 'css'

exports.getType = (file) ->
  extname = path.extname(file).substring 1
  extension = thimble.extensions[extname]
  extname = if extension then extension else extname

  type = types[extname]
  return if type then type else false
  
###
  Asset Compilers
###

# Coffeescript
exports.coffeescript = (file, options, fn) ->
  options = options._thimble
  engine = requires.coffeescript || (requires.coffeescript = require('coffee-script'))
  
  read file, options, (err, str) ->
    fn err, engine.compile(str)

# Stylus
exports.stylus = (file, options, fn) ->
  options = options._thimble
  engine = requires.stylus || (requires.stylus = require('stylus'))
  
  read file, options, (err, str) ->
    return fn(err) if err
    
    styl = engine(str)
  
    try
      nib = require "nib"
      styl.use(nib())
    catch error
      # Do nothing
  
    styl
      .set("filename", file)
      .include(options.root)
      .render (err, css) ->
        fn err, css

###
  Compilers
###

# Handlebars
exports.handlebars = (file, locals, fn) ->
  engine = requires.handlebars || (requires.handlebars = require('handlebars'))

  read file, locals, (err, str) ->
    return fn(err) if err
    try
      locals.filename = file
      tmpl = engine.compile str, locals
      fn null, tmpl(locals)
    catch err
      fn err
  
exports.markdown = (file, locals, fn) ->
  console.log 'coming **soon** ;-P'
    
###
  consolidate.js compilers
  Author : TJ Holowaychuk - @visionmedia
  URL : https://github.com/visionmedia/consolidate.js
###

# Jade
exports.jade = (file, locals, fn) ->
  engine = requires.jade or (requires.jade = require("jade"))
  engine.renderFile file, locals, fn
