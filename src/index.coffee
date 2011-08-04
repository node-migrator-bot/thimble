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

render = exports.render = (app) ->
  baseDir = path.dirname app
  
  fs.readFile app, "utf8", (err, html) ->
    throw err if err

    parser = new CommentParser html, baseDir
    parser.parse null, null, (document) ->
      res.send document.innerHTML

middleware = exports.middleware = (appDir) ->
  return (req, res, next) ->
    root = appDir
    url = req.url
    assetPath = path.resolve(root + url)


    Plugin = plugin url

    if Plugin is false
      next()
      return
            
    fs.readFile assetPath, "utf8", (err, contents) ->
      throw err if err

      output = (err, out) ->
        throw err if err
        
        if not res.getHeader "content-type"
          # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
          header = getHeader "blah.#{Plugin.type}"
          res.setHeader('Content-Type', header)
          # console.log header
          
        
        # console.log out
        res.send out
      
      Plugin.render contents, assetPath, output

# Implementation pulled from static.js in Connect
getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)
  
module.exports = exports
