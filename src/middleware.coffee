path = require "path"
fs = require "fs"
mime = require "mime"
parse = require('url').parse
thimble = require './thimble'

middleware = exports.middleware = (options) ->
  root = options.root
  
  # Add custom paths
  defaultPath = addPaths options

  # Return middleware
  return (req, res, next) ->
    url = req.url
    console.log parse req.url
    
    # Allow custom paths
    if url.split(':').length > 1
      url = path.basename(url)
      url = defaultPath url
      
    if url
      req.url = url
    else
      return next()
    
    assetPath = path.resolve(root + '/' + url)

    thimble.utils.read assetPath, (err, content) ->
      if err
        console.log req.method
        return next(err)
      
      if !content
        return next()
        
      thimble.compile(assetPath) content, options, (err, str) ->
        if err
          return next(err)
        
        if !content
          return next()
        
        if not res.getHeader "content-type"
          # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
          header = getHeader 'blah.' + thimble.compile.getType(assetPath) 
          res.setHeader('Content-Type', header)          

        res.send content
  
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