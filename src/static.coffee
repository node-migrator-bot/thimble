fs = require "fs"
{basename, extname} = require "path"

###
  Export version
###
exports.__defineGetter__ 'version', ->
  JSON.parse(
    fs.readFileSync(__dirname + '/../package.json', 'utf8')
  ).version

###
  Extension to View Map
###
extensions = exports.extensions = 
  'styl'   : 'stylus'
  'coffee' : 'coffeescript'
  'hb'     : 'handlebars'
  'mu'     : 'hogan'
  'md'     : 'markdown'

###
  Read in all the plugins and make them available
###
fs.readdirSync(__dirname + "/plugins").forEach (filename) ->
  if not /\.(js|coffee)$/.test(filename) then return
  ext = extname filename
  name = basename(filename, ext)
  
  load = ->
    require "./plugins/" + name
  
  # Lazy load the plugins
  exports.__defineGetter__ name, load
  

# Export object
module.exports = exports