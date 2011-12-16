
###
  thimble.coffee is the main driver
###
fs = require "fs"
path = require "path"

_ = require "underscore"

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
  thim = 
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
    thim.settings[key] = value

  # Implicit plugins
  implicit = []

  # Add the flattener
  implicit.push exports.flatten
  
  # Add the embedder
  implicit.push exports.embed

  # Support options
  thim.settings.support = 
    files : []

  # Add the support plugin
  implicit.push exports.support()

  # Push the implicit commands on the stack before the user plugins
  thim.stack = implicit.concat thim.stack  

  # Add prototype functions to the instance
  thim.__proto__ = require './proto'
  
  return thim

# Expose .create()
exports.create = module.exports

###
  Export version
###

exports.version = JSON.parse(
  fs.readFileSync(__dirname + '/../package.json', 'utf8')
).version

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