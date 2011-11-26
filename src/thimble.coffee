
###
  thimble.coffee is the main driver
###
fs = require "fs"

_ = require "underscore"
cheerio = require "cheerio"

flattener = require "./flatten"

configuration = {}

emitter = exports.emitter = new (require('events').EventEmitter)()

# Pull in all the tags
tags = fs.readdirSync(__dirname + '/tags')
for tag in tags
  if tag is '.DS_Store' then continue
  require('./tags/' + tag)

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

render = exports.render = (content, directory, callback) ->
  $ = cheerio.load content
  emitter.emit "before:flattened", $
  content = $.html()
  
  flattener.flatten content, directory, configuration, (err, flattened) ->
    $ = cheerio.load flattened
    emitter.emit "after:flattened", $
    callback null, $.html()
  

module.exports = exports
