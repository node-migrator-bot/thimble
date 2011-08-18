path = require "path"
fs = require "fs"
mime = require "mime"
plugin = require("./plugin")('./plugins/asset')

middleware = exports.middleware = (appDir, options) ->
  (req, res, next) ->
    root = appDir
    url = req.url
    assetPath = path.resolve(root + url)
    
    Plugin = plugin url

    if Plugin is false
      return next()
            
    fs.readFile assetPath, "utf8", (err, contents) ->
      throw err if err

      output = (err, out) ->
        throw err if err
        
        if not res.getHeader "content-type"
          # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
          header = getHeader "blah.#{Plugin.type}"
          res.setHeader('Content-Type', header)          
        
        res.send out
      
      Plugin.render contents, assetPath, options or {}, output

# Implementation pulled from static.js in Connect
getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)
  
module.exports = exports