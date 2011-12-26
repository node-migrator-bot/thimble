
###
  Load modules
###

path = require 'path'
fs = require 'fs'

thimble = require '../thimble'

###
  Used to compile languages for both assets and views
###

exports = module.exports = (file) ->
  # Allow files or compilers to be specified
  if file.indexOf '.' >= 0
    extname = path.extname(file).substring(1)
  else
    extname = file
    
  extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname

  return (content, options, next) ->
    compiler = exports[extname]

    # Compile the file
    if compiler
      compiler content, options, (err, str) ->
        return next(err, str)
    else
      return next(null, content)

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
  
###
  Asset Compilers
###

# Coffeescript
exports.coffeescript = (content, options, fn) ->
  options = options._thimble
  engine = requires.coffeescript || (requires.coffeescript = require('coffee-script'))
  
  try
    str = engine.compile(content)
    fn null, str
  catch err
    fn err

# Stylus
exports.stylus = (content, options, fn) ->
  options = options._thimble
  engine = requires.stylus || (requires.stylus = require('stylus'))
  
  styl = engine str
  
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
      fn err, css

###
  Compilers
###
  
# Markdown
exports.markdown = (content, options, fn) ->
  engine = requires.markdown || (requires.markdown = require('github-flavored-markdown'))
  
  try
    str = engine.parse content
    fn null, str
  catch err
    fn err

# Jade
exports.jade = (content, options, fn) ->
  engine = requires.jade or (requires.jade = require("jade"))
  
  try
    # Compile jade without any locals
    str = engine.compile(content, options)({})
    fn null, str
  catch err
    fn err
  
