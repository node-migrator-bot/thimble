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
      if asset.src        
        fs.readFile main + "/" + asset.src, "utf8", (err, code) ->
          Plugin = plugin(asset.src)
          if Plugin
            Plugin.render code, asset.src, options = {}, (err, js) ->
              output[i] = js
              done output if finished()
          else
            output[i] = code
            done output if finished()
      else 
        Plugin = plugin("blah."+asset.type.split("/").pop())
        if Plugin
          Plugin.render asset.firstChild.nodeValue, "", options = {}, (err, js) ->
            output[i] = js
            done output if finished()
        else
          output[i] = asset.innerHTML
          done output if finished()


write = exports.write = (bundle, public) ->
  fs.writeFile public + "/build.js", bundle, "utf8", (err) ->
    emitter.emit "written", err
  
modify = exports.modify = (document) ->
  script = document.createElement "script"
  script.src = "build.js"
  script.type = "text/javascript"
  script.defer = "defer"

  html = document.children[0]
  html.appendChild(script)
  
  emitter.emit "modified"
  
module.exports = exports
  