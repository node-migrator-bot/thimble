
###
  Load modules
###

path = require "path"

thimble = require "../thimble"

###
  Used to compile languages for both assets and views
###

exports = module.exports = (file, locals = {}) ->
  extname = path.extname(file).substring(1)
  extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname
  
  return (content, options, next) ->
  
    if !exports[extname]
      return next(null, content)

    exports[extname] file, locals, (err, str) ->
      return next(err, str)

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
  str = cache[file]
  return fn(null, str)  if options.cache and str
  fs.readFile file, "utf8", (err, str) ->
    return fn(err)  if err
    cache[file] = str  if options.cache
    fn null, str

###
  Asset Compilers
###

# Coffeescript
exports.coffeescript = (file, options, fn) ->
  engine = requires.coffeescript || (requires.coffeescript = require('coffeescript'))
  
  read file, options, (err, str) ->
    fn null, engine.compile(str)

# Stylus
exports.stylus = (file, options, fn) ->
  engine = requires.stylus || (requires.stylus = require('stylus'))
  
  read file, options, (err, str) ->

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
        throw err if err
        output null, css
    
###
  Consolidate Compilers
  Author : TJ Holowaychuk - @visionmedia
  URL : https://github.com/visionmedia/consolidate.js
###

# Jade
exports.jade = (file, options, fn) ->
  engine = requires.jade or (requires.jade = require("jade"))
  engine.renderFile file, options, fn

# Swig
exports.swig = (file, options, fn) ->
  engine = requires.swig or (requires.swig = require("swig"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      tmpl = engine.compile(str, options)
      fn null, tmpl(options)
    catch err
      fn err

# Liquor
exports.liquor = (file, options, fn) ->
  engine = requires.liquor or (requires.liquor = require("liquor"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      tmpl = engine.compile(str, options)
      fn null, tmpl(options)
    catch err
      fn err

# EJS
exports.ejs = (file, options, fn) ->
  engine = requires.ejs or (requires.ejs = require("ejs"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      tmpl = engine.compile(str, options)
      fn null, tmpl(options)
    catch err
      fn err

# Eco
exports.eco = (file, options, fn) ->
  engine = requires.eco or (requires.eco = require("eco"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      fn null, engine.render(str, options)
    catch err
      fn err

# Jazz
exports.jazz = (file, options, fn) ->
  engine = requires.jazz or (requires.jazz = require("jazz"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      tmpl = engine.compile(str, options)
      tmpl.eval options, (str) ->
        fn null, str
    catch err
      fn err

# JQTPL
exports.jqtpl = (file, options, fn) ->
  engine = requires.jqtpl or (requires.jqtpl = require("jqtpl"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      engine.template file, str
      fn null, engine.tmpl(file, options)
    catch err
      fn err

exports.haml = (file, options, fn) ->
  engine = requires.hamljs or (requires.hamljs = require("hamljs"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      options.filename = file
      options.locals = options
      fn null, engine.render(str, options).trimLeft()
    catch err
      fn err

# Whiskers
exports.whiskers = (file, options, fn) ->
  engine = requires.whiskers or (requires.whiskers = require("whiskers"))
  read file, options, (err, str) ->
    return fn(err)  if err
    try
      fn null, engine.render(str, options)
    catch err
      fn err

      
