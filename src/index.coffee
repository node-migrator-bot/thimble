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
CommentParser = require "./parsers/comments"

render = exports.render = (app, callback) ->
  baseDir = path.dirname app
  
  fs.readFile app, "utf8", (err, html) ->
    throw err if err

    parser = new CommentParser html, baseDir
    parser.parse null, null, (document) ->
      callback document

middleware = exports.middleware = require('./middleware').middleware
  
module.exports = exports
