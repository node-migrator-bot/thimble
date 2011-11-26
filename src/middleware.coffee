path = require "path"
fs = require "fs"
mime = require "mime"
language = require("./language")('./languages')
utils = require './utils'

middleware = exports.middleware = (root, options) ->
  # Add support files
  # support = addSupport options
  
  # Return middleware
  (req, res, next) ->
    url = req.url
    
    # name = path.basename url
    # if !path.extname name and support(name)
    #   assetPath = support(name)
    
    assetPath = path.resolve(root + url)

    plugin = language assetPath
    if plugin is false
      return next()
            
    fs.readFile assetPath, "utf8", (err, contents) ->
      if err
        console.log err.message
        res.send 500

      output = (err, out) ->
        if err
          console.log err.message
          res.send 500
        
        if not res.getHeader "content-type"
          # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
          header = getHeader "blah.#{plugin.type}"
          res.setHeader('Content-Type', header)          
        
        res.send out
      
      plugin.compile contents, assetPath, options or {}, output

# addSupport = (supportDir) ->
#   supportFiles = {}
#   support = options.support
#   root = options.root
#   
#   files = fs.readdirSync supportDir
# 
#   for file in files
#     ext = path.extname file
#     name = path.basename file, ext
#     console.log name
#     
#     supportFiles[name] = supportDir + "/" + file
# 
#   return (file) ->
#     if(supportFiles[file]) then supportFiles[file] else false

# Implementation pulled from static.js in Connect
getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)
  
module.exports = exports.middleware