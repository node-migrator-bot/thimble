src = "#{__dirname}/.."
{countdown} = require "#{src}/utils"
fs = require "fs"
plugin = require("#{src}/plugin")("plugins/asset/")
_ = require "underscore"
emitter = new (require("events").EventEmitter)()

build = exports.build = (assets, public, main, callback) ->
  
  emitter.once "rendered", (output) ->
    bundle = output.join ""
    write bundle, public
    
  emitter.once "written", (err) ->
    modify assets[0].ownerDocument
    
  emitter.once "modified", () ->
    callback null

  render assets, main

render = exports.render = (assets, main) ->
  finished = countdown assets.length

  done = (output) ->
    emitter.emit "rendered", output

  output = []
  for asset, i in assets    
    do (asset, i) ->
      if asset.href        
        fs.readFile main + "/" + asset.href, "utf8", (err, code) ->
          Plugin = plugin(asset.href)
          if Plugin
            Plugin.render code, asset.href, options = {}, (err, js) ->
              output[i] = js
              done output if finished()
          else
            output[i] = code
            done output if finished()
      else
        throw "Not yet implemented yet! This will allow style tags, to be bundled correct"

write = exports.write = (bundle, public) ->
  fs.writeFile public + "/build.css", bundle, "utf8", (err) ->
    emitter.emit "written", err

modify = exports.modify = (document) ->
  link = document.createElement "link"
  link.href = "build.css"
  link.rel = "stylesheet"

  head = document.getElementsByTagName("head")[0]
  head.appendChild link
  
  emitter.emit "modified"
 
module.exports = exports