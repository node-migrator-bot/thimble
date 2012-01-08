
###
  thimble.coffee is the main driver
###
fs = require "fs"
{basename, extname, normalize, resolve} = require "path"

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
  if !configuration.root
    throw "Thimble: You need to specify a root directory"
  
  configuration = _.clone(configuration)

  thim = 
    stack : []
    settings : {}
  
  # Resolve the root path
  configuration.root = resolve(configuration.root)
  
  # Get the env from how $ node is run
  env = process.env.NODE_ENV || 'development'

  # Set the defaults
  _.defaults configuration,
    env : env
    paths : {}
    template : 'JST'
    namespace : 'window'
    'support path' : normalize(__dirname + '/../support/')
    'support files' : []
    plugins : ['support']
    instance : thim
    
  for key, value of configuration
    thim.settings[key] = value

  # Implicit plugins
  implicit = []
  # console.log thim
  # Add the implicit plugins
  for plugin in thim.settings.plugins
    implicit.push exports[plugin]

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
  Hook static application modules onto thimble object
###

exports.utils = require './utils'
exports.middleware = require './middleware'

###
  Read in all the plugins
###
fs.readdirSync(__dirname + "/plugins").forEach (filename) ->
  if not /\.(js|coffee)$/.test(filename) then return
  ext = extname filename
  name = basename(filename, ext)
  
  load = ->
    require "./plugins/" + name
  
  # Lazy load the plugins
  exports.__defineGetter__ name, load


module.exports = exports