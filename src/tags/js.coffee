src = "#{__dirname}/.."
{countdown} = require "#{src}/utils"
fs = require "fs"
plugin = require("#{src}/plugin")("plugins/asset/")
_ = require "underscore"
emitter = new (require("events").EventEmitter)()
$ = require("jquery");

build = exports.build = (assets, options, callback) ->
  public = options.public
  root = options.root
  
  emitter.once "rendered", (output) ->
    bundle = output.join ";"
    write bundle, public
    
  emitter.once "written", (err) ->
    modify assets[0].ownerDocument
    
  emitter.once "modified", () ->
    callback null

  render assets, root, options

render = exports.render = (assets, root) ->
  finished = countdown assets.length
  
  done = (output) ->
    emitter.emit "rendered", output

  output = []
  for asset, i in assets    
    do (asset, i) ->
      source = asset.src
      
      if source          
        fs.readFile source, "utf8", (err, code) ->
          throw err if err
          Plugin = plugin(asset.src)
          if Plugin
            Plugin.compile code, asset.src, options = {}, (err, js) ->
              output[i] = js
              done output if finished()
          else
            output[i] = code
            done output if finished()
      else
        Plugin = plugin("blah."+asset.type.split("/").pop())
        if Plugin
          Plugin.compile asset.firstChild.nodeValue, "", options = {}, (err, js) ->
            output[i] = js
            done output if finished()
        else
          # Use asset.firstChild.nodeValue so it doesn't escape quotes
          output[i] = asset.firstChild.nodeValue
          done output if finished()

write = exports.write = (bundle, public) ->
  fs.writeFile public + "/build.js", bundle, "utf8", (err) ->
    emitter.emit "written", err
  
modify = exports.modify = (document) ->
  # Remove the other script tags
  $("script", document).remove();
    
  script = document.createElement "script"
  script.src = "build.js"
  script.type = "text/javascript"
  script.defer = "defer"

  html = document.children[0]
  html.appendChild(script)
  
  emitter.emit "modified"
  
module.exports = exports
  