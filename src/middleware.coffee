
{normalize, join, basename, extname, basename} = require("path")
fs = require "fs"
mime = require "mime"
parse = require('url').parse
thimble = require './thimble'

middleware = exports.middleware = (options) ->
  root = options.root
  
  # Add custom paths
  # defaultPath = addPaths options

  # Return middleware
  return (req, res, next) ->
    head = 'HEAD' == req.method
    get = 'GET' == req.method
  
    # Ignore non-get requests
    if !head and !get
      return next()
  
    url = parse req.url
    path = decodeURIComponent url.pathname
  
    # Join and normalize from root
    path = normalize(join(options.root, path))

    fs.stat path, (err, stat) ->
      # Ignore ENOENT (no such file or directory)
      if err
        if err.code is 'ENOENT' or err.code is 'ENAMETOOLONG'
          return next()
        else
          return next(err)
      else if stat.isDirectory()
        return next()
    
    
      thimble.utils.read path, (err, content) ->
        if err or !content
          return next(err)

        thimble.compile(path) content, options, (err, str) ->
          if err or !str
            return next(err)
          if not res.getHeader "content-type"
            # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
            
            ext = thimble.compile.getType(path) || extname(path)
            header = getHeader('blah.' + ext)

            res.setHeader('Content-Type', header)          

          res.send str
  
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
      ext = extname file
      name = basename file, ext
      assets[name] = p + "/" + file
    
    paths[namespace] = assets
    
  return (namespace) ->
    namespace = namespace.split(':')
    file = namespace.pop()
    return paths[namespace.join(':')][file] || false


module.exports = exports.middleware