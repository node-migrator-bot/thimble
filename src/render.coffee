# Used to render a thimble template

path = require "path"
fs = require "fs"
parser = require "./parser"
plugins = require("./plugin")("./plugins/document")

render = exports.render = (app, locals = {}, callback) ->
  # Always passing in all the locals might screw something up,
  # Instead add new options here each time. Shouldn't be too many...
  cOpts = {}
  cOpts.root = locals.root
  cOpts.layout = locals.layout or false

  parser.parse app, cOpts, (err, code) ->
    plugin = plugins app
    
    if !plugin
      ext = path.extname app
      callback(
        "Couldn't find plugin(#{ext}) for #{app}"
        code
      )
    
    plugin.render code, app, locals, (err, templateFunction) ->
      rendered = templateFunction locals
      callback null, rendered
    