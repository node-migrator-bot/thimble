
###
  thimble.coffee is the main driver
###
fs = require "fs"
path = require "path"

_ = require "underscore"

# fs = require "fs"
# 
# cheerio = require "cheerio"
# 
# # flattener = require "./flatten"
# 
# configuration = {}
# # 
# emitter = exports.emitter = new (require('events').EventEmitter)()
# 
# configure = exports.configure = (options) ->
#   # Defaults
#   _.extend configuration,
#     root :  './views'
#     env :   'development'
#     paths : {}
# 
#   _.extend configuration, options
  
# configure = exports.configure = (env, fn) ->
#   envs = 'all'
#   args = [].slice.call arguments
#   fn = args.pop()
#   # if args.length the
#   
# start = exports.start = (expressServer) ->
#   server = require "./server"
#   server.boot expressServer, configuration

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

create = exports.create = (configuration = {}) ->
  t = 
    settings : {}
    stack : []
  
  # Set the defaults
  _.extend configuration,
    root :  './views'
    env :   'all'
    paths : {}
  
  for key, value of configuration
    t.settings[key] = value

  t.__proto__ = require './proto'
  
  return t


fs.readdirSync(__dirname + "/plugins").forEach (filename) ->
  if not /\.(js|coffee)$/.test(filename) then return
  ext = path.extname filename
  name = path.basename(filename, ext)
  
  load = ->
    require "./plugins/" + name
  
  exports.__defineGetter__ name, load


module.exports = exports