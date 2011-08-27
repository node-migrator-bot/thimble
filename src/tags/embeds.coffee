EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
utils = require "../utils"
build = require("../builder")
$ = require "jquery"

exports.build = (assets, options, callback) ->
  console.log "Embeds not supported right now"
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
