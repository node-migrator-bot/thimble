path = require "path"
fs = require "fs"
pluginPath = "#{__dirname}/../plugins/"
mime = require "mime"

files = fs.readdirSync pluginPath
plugins = {}

for file in files
  fileArr = file.split "."
  fileArr.pop()
  ext = fileArr.join "."
  plugins[ext] = file

# Reason you do middleware = exports.middleware is that it lets you 
# use functions like setHeader in callback functions. 
# This way you don't have to bind "this"

middleware = exports.middleware = (appDir) ->
  return (req, res, next) ->
    url = req.url
    ext = url.split(".").pop()
    root = appDir

    if !plugins[ext]
      next()
      return

    plugin = require pluginPath + plugins[ext]
    assetPath = path.resolve(root + url)

    fs.readFile assetPath, "utf8", (err, contents) ->
      throw err if err

      output = (out) ->
        if not res.getHeader "content-type"
          # Name doesn't matter. mime just cares about .css, .js, .png, etc. not the name or if file exists
          header = getHeader "blah.#{plugin.type}"
          res.setHeader('Content-Type', header);
        res.send out
      
      plugin.render contents, assetPath, output

# Implementation pulled from static.js in Connect
getHeader = exports.getHeader = (assetPath) ->
  type = mime.lookup assetPath
  charset = mime.charsets.lookup type
  charset = if charset then "; charset=#{charset}" else ""
  return (type + charset)
  
module.exports = exports

