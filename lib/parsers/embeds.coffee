lib = "#{__dirname}/.."
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
utils = require lib + "/utils.coffee"
build = require(lib + "/builder.coffee")
$ = require "jquery"

exports.build = (assets, public, main, output) ->

  finished = utils.countdown assets.length

  for asset in assets
    appPath = main + "/" + asset.src
    builder = new build(appPath, public, {})

    do (asset) ->
      builder.build (err, html) ->
        throw err if err
        
        $(asset).replaceWith html
        
        if finished()
          output null

module.exports = exports
