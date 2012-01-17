
###
  Load modules
###

path = require 'path'
fs = require 'fs'

_ = require "underscore"

thimble = require '../thimble'

###
  Used to compile languages for both assets and views
###

exports = module.exports = (file, locals = {}) ->
  # Allow files or compilers to be specified
  if ~file.indexOf('.')
    extname = path.extname(file).substring(1)
  else
    extname = file

  extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname
  compiler = exports[extname]

  return (content, options, next) ->

    # Compile the file
    if compiler
      if locals
        options.locals = locals
        
      compiler content, options, (err, str) ->
        # Reset
        options.locals = {}
        
        return next(err, str)
    else
      return next(false, content)

###
  Requires Cache
###

requires = {};

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
  
precompile = (options) ->
  if(options.locals and options.env is 'production')
    return true
  else
    return false
 
###
  Asset Compilers
###

# Coffeescript
exports.coffeescript = (content, options, cb) ->
  engine = requires.coffeescript || (requires.coffeescript = require('coffee-script'))

  try
    str = engine.compile(content)
    cb null, str
  catch err
    cb err

# Stylus
exports.stylus = (content, options, cb) ->
  engine = requires.stylus || (requires.stylus = require('stylus'))
  
  styl = engine content
  
  # Try adding nib
  try
    nib = requires.nib || (requires.nib = require('nib'))
    styl.use(nib())
  catch error
    # Do nothing - nib wasn't added

  styl
    .set('filename', options.source)
    .include(options.root)
    .render (err, css) ->
      cb err, css

###
  Compilers
###
  
# Markdown
exports.markdown = (content, options, cb) ->
  engine = requires.markdown || (requires.markdown = require('github-flavored-markdown'))
  
  try
    str = engine.parse content
    cb null, str
  catch err
    cb err

# Jade
exports.jade = (content, options, cb) ->
  engine = requires.jade or (requires.jade = require("jade"))
  
  try
    # Compile jade without any locals
    str = engine.compile(content, options)({})
    cb null, str
  catch err
    cb err

###
  Templating Compilers
###

# Handlebars
exports.handlebars = (content, options, cb) ->
  engine = requires.handlebars || (requires.handlebars = require('handlebars'))

  try
    fn = engine.compile(content, options)
    str = fn(options.locals || {})
    cb(null, str)
  catch err
    cb err
    
# Hogan
exports.hogan = (content, options, cb) ->
  engine = requires.hogan || (requires.hogan = require('hogan.js'))
  
  try
    fn = engine.compile(content, options)
    str = fn.render(options.locals || {})
    cb(null, str)
  catch err
    cb(err)
