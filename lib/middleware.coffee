path = require "path"
fs = require "fs"
mime = require "mime"
lib = __dirname
plugin = require(lib + "/plugin.coffee")

# Reason you do middleware = exports.middleware is that it lets you 
# use functions like setHeader in callback functions. 
# This way you don't have to bind "this"

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
        
        # if not res.getHeader "content-type"
        #   # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
        #   header = getHeader "blah.#{Plugin.type}"
        #   res.setHeader('Content-Type', header)
        #   console.log header
          
        console.log out
        res.send out
      
      Plugin.render contents, assetPath, output

# Implementation pulled from static.js in Connect
getHeader = exports.getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)
  
module.exports = exports.middleware

