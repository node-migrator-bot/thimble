
###
  thimble.coffee is the main driver
###
fs = require "fs"

_ = require "underscore"
cheerio = require "cheerio"

flattener = require "./flatten"

configuration = {}

emitter = exports.emitter = new (require('events').EventEmitter)()

configure = exports.configure = (options) ->
  # Defaults
  _.extend configuration,
    root :  './views'
    env :   'development'
    paths : {}

  _.extend configuration, options
  
start = exports.start = (expressServer) ->
  server = require "./server"
  server.boot expressServer, configuration
  

module.exports = exports
