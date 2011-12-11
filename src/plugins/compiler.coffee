
###
  Load modules
###

path = require "path"
fs = require "fs"

thimble = require "../thimble"

###
  Used to compile languages for both assets and views
###

exports = module.exports = (file, locals = {}) ->
  extname = path.extname(file).substring(1)
  extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname
  
  return (content, options, next) ->
    compile = exports[extname]
    
    # Compile the file
    if compile
      exports[extname] file, locals, (err, str) ->
        return next err, str
    else
      return next null, content

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
exports.coffeescript = (file, locals, fn) ->
  engine = requires.coffeescript || (requires.coffeescript = require('coffeescript'))
  
  read file, locals, (err, str) ->
    fn null, engine.compile(str)

# Stylus
exports.stylus = (file, locals, fn) ->
  engine = requires.stylus || (requires.stylus = require('stylus'))
  
  read file, locals, (err, str) ->

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

# Swig
exports.swig = (file, locals, fn) ->
  engine = requires.swig or (requires.swig = require("swig"))
  read file, locals, (err, str) ->
    return fn(err) if err
    try
      locals.filename = file
      tmpl = engine.compile(str, locals)
      fn null, tmpl(locals)
    catch err
      fn err

# Liquor
exports.liquor = (file, locals, fn) ->
  engine = requires.liquor or (requires.liquor = require("liquor"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      tmpl = engine.compile(str, locals)
      fn null, tmpl(locals)
    catch err
      fn err

# EJS
exports.ejs = (file, locals, fn) ->
  engine = requires.ejs or (requires.ejs = require("ejs"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      tmpl = engine.compile(str, locals)
      fn null, tmpl(locals)
    catch err
      fn err

# Eco
exports.eco = (file, locals, fn) ->
  engine = requires.eco or (requires.eco = require("eco"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      fn null, engine.render(str, locals)
    catch err
      fn err

# Jazz
exports.jazz = (file, locals, fn) ->
  engine = requires.jazz or (requires.jazz = require("jazz"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      tmpl = engine.compile(str, locals)
      tmpl.eval locals, (str) ->
        fn null, str
    catch err
      fn err

# JQTPL
exports.jqtpl = (file, locals, fn) ->
  engine = requires.jqtpl or (requires.jqtpl = require("jqtpl"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      engine.template file, str
      fn null, engine.tmpl(file, locals)
    catch err
      fn err

exports.haml = (file, locals, fn) ->
  engine = requires.hamljs or (requires.hamljs = require("hamljs"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      locals.filename = file
      locals.locals = locals
      fn null, engine.render(str, locals).trimLeft()
    catch err
      fn err

# Whiskers
exports.whiskers = (file, locals, fn) ->
  engine = requires.whiskers or (requires.whiskers = require("whiskers"))
  read file, locals, (err, str) ->
    return fn(err)  if err
    try
      fn null, engine.render(str, locals)
    catch err
      fn err

      
