path = require "path"
fs = require "fs"
commentParser = require "./plugins/document/comments"

render = exports.render = (app, locals = {}, callback) ->
  
  fs.readFile app, "utf8", (err, html) ->
    throw err if err
    
    options = {}
    
    if locals.outer
      options.outer = locals.outer
    
    commentParser.render html, app, options, (html) ->
      callback html