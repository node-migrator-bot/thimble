path = require "path"
fs = require "fs"
mime = require "mime"
language = require("./language")
utils = require './utils'

middleware = exports.middleware = (root, options) ->
  # Add custom paths
  defaultPath = addPaths options
  
  # Return middleware
  (req, res, next) ->
    url = req.url
    
    # Allow custom paths
    if url.split(':').length > 1
      url = path.basename(url)
      url = defaultPath url
      
    if url
      req.url = url
    else
      return next()
    

    plugin = language url
    if plugin is false
      return next()
            
    assetPath = path.resolve(root + '/' + url)

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

# Implementation pulled from static.js in Connect
getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)

addPaths = (options) ->
  paths = {}
  for namespace, p of options.paths
    assets = {}
    files = fs.readdirSync options.root + "/" + p
    
    for file in files
      ext = path.extname file
      name = path.basename file, ext
      assets[name] = p + "/" + file
    
    paths[namespace] = assets
    
  return (namespace) ->
    namespace = namespace.split(':')
    file = namespace.pop()
    return paths[namespace.join(':')][file] || false


module.exports = exports.middleware