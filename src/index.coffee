###
  index.coffee --- Matt Mueller
  
  The purpose of this provide an application interface for developing applications.
  It has two main functions : middleware(appDir), and render(file)
  
  middleware - will load all the required assets
  render - will parse the html comments
  
###

path = require "path"
fs = require "fs"
mime = require "mime"
plugin = require "./plugin"
CommentParser = require "./plugins/document/comments"
_ = require "underscore"

render = exports.render = (app, locals = {}, callback) ->
  baseDir = path.dirname app
  
  fs.readFile app, "utf8", (err, html) ->
    throw err if err
    
    document = new CommentParser html, baseDir
    document.outer locals.outer if locals.outer
    
    document.parse (html) ->
      callback html

middleware = exports.middleware = require('./middleware').middleware
  
module.exports = exports
