
###
  thimble.coffee is the main driver
###
fs = require "fs"
path = require "path"

_ = require "underscore"

###
  Version
###

version = '0.0.1'

###
  Public: creates a thimble instance. Sets up the object and 
    passes in the configuration
  
  configuration - configuration values for the server
  
  Examples
   
    var t = thimble.create({
      root : "./client",
      env : "production",
      paths : {
        support : "./client/support"
        vendor : "./client/vendor"
      }
    });
  
  Returns: an thimble instance Object 
###

exports = module.exports = (configuration = {}) ->
  t = 
    settings : {}
    stack : []
  
  # Get the env from how $ node is run
  env = process.env.NODE_ENV || 'development'
  
  # Set the defaults
  _.defaults configuration,
    root :  './views'
    env :   env
    paths : {}
    template : 'JST'
    namespace : 'window'
    
  for key, value of configuration
    t.settings[key] = value

  # Add prototype functions to the instance
  t.__proto__ = require './proto'
  
  return t

# Expose .create()
exports.create = module.exports

###
  Export version
###

exports.version = version

###
  Extension to View Map
###

extensions = exports.extensions = 
  'styl'   : 'stylus'
  'coffee' : 'coffeescript'
  'hb'     : 'handlebars'
  'mu'     : 'handlebars'
  'md'     : 'markdown'

###
  Read in all the plugins
###
fs.readdirSync(__dirname + "/plugins").forEach (filename) ->
  if not /\.(js|coffee)$/.test(filename) then return
  ext = path.extname filename
  name = path.basename(filename, ext)
  
  load = ->
    require "./plugins/" + name
  
  # Lazy load the plugins
  exports.__defineGetter__ name, load


module.exports = exports