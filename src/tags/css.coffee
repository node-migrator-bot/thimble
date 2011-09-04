src = "#{__dirname}/.."
{countdown} = require "#{src}/utils"
fs = require "fs"
plugin = require("#{src}/plugin")("plugins/asset/")
_ = require "underscore"
emitter = new (require("events").EventEmitter)()
$ = require "jquery"

build = exports.build = (assets, options, callback) ->
  public = options.public
  root = options.root

  emitter.once "rendered", (output) ->
    bundle = output.join ""
    write bundle, public
    
  emitter.once "written", (err) ->
    throw err if err
    modify assets[0].ownerDocument
    
  emitter.once "modified", () ->
    callback null

  render assets, root, options

render = exports.render = (assets, root, options) ->
  finished = countdown assets.length

  done = (output) ->
    emitter.emit "rendered", output

  output = []
  for asset, i in assets    
    do (asset, i) ->
      source = asset.href
      if source
        source = root + "/" + source
        fs.readFile source, "utf8", (err, code) ->
          throw err if err
          Plugin = plugin(asset.href)
          if Plugin
            Plugin.compile code, asset.href, options = {}, (err, js) ->
              output[i] = js
              done output if finished()
          else
            output[i] = code
            done output if finished()
      else
        # This is a STYLE tag
        Plugin = plugin("blah."+asset.type.split("/").pop())
        if Plugin
          # Trim fixes stylus
          style = $.trim(asset.firstChild.nodeValue)
          Plugin.compile style, "", options = {}, (err, js) ->
            output[i] = js
            done output if finished()
        else
          output[i] = asset.firstChild.nodeValue
          done output if finished()

write = exports.write = (bundle, public) ->
  fs.writeFile public + "/build.css", bundle, "utf8", (err) ->
    emitter.emit "written", err

modify = exports.modify = (document) ->
  # Remove all other LINK tags
  $('link', document).remove()
  
  link = document.createElement "link"
  link.href = "build.css"
  link.rel = "stylesheet"

  head = document.getElementsByTagName("head")[0]
  if head is undefined
    throw "You have no head! Seriously, no <head>. Valid syntax is required for this portion of the show. Maybe you forgot the layout flag?"
  head.appendChild link
  
  emitter.emit "modified"
 
module.exports = exports