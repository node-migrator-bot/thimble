jsdom = require("jsdom").jsdom
EventEmitter = require("events").EventEmitter
_ = require "underscore"
emitters = {}
fs = require "fs"
path = require "path"
lib = __dirname
parserPath = lib + "/parsers"
utils = require lib + "/utils.coffee"

build = exports.build = (file, public, options = {}) ->
  fileDir = path.dirname file
  emitter = emitters[file] = new EventEmitter()

  emitter.once "read", (code) ->
    document = jsdom(code)
    pullAssets document, fileDir, emitter
    
  emitter.once "pulled", (assets) ->
    parseAssets assets, public, emitter
    
  emitter.once "built", () ->
    console.log "Successfully built the files"
    
  readFile file, emitter

parseAssets = (assets, public, emitter) ->
  assetTypes = _.keys(assets)
  finished = utils.countdown assetTypes.length

  # ** All assets get bundled together so maybe we can just build the whole js and css files, then move all the assets together
  # -- Return null if success, true if failure **
  
  callback = (err, filepath) ->
    throw "Unable to build..." if err
    
    if finished()
      emitter.emit "built"
  
  for type in assetTypes
    parser = require parserPath + "/#{type}.coffee"
    parser.build assets[type], public, callback


pullAssets = (document, fileDir, emitter) ->
  assets = {}
  
  
  assets["js"] = pullAssetType "script", document
  assets["embeds"] = pullAssetType "embed", document
  assets["css"] = pullAssetType "link", document, "href"
  assets["images"] = pullAssetType "img", document

  # Remove empty objects
  assets = removeEmpties assets
  
  # Makes all the links absolute
  assets = makeAbsolute fileDir, assets

  emitter.emit "pulled", assets

pullAssetType = (tag, document, attr = "src") ->
  tags = document.getElementsByTagName tag

  sources = []
  for t in tags
    sources.push t[attr]
    
  return sources

removeEmpties = (assets) ->
  for type, asset of assets
    if asset.length is 0
      delete assets[type]
      
  return assets

makeAbsolute = (fileDir, assets) ->

  for type, asset of assets
    assets[type] = _(asset).map (file) ->
      return fileDir + "/" + file
    
  return assets

readFile = (file, emitter) ->
  fs.readFile file, "utf8", (err, code) ->
    throw err if err
    
    emitter.emit "read", code

# -----------------

# buildAssets = (assets, main, public) ->
#   console.log "hi"
# 
# read = (main) ->
#   emitter.once "read", (code) ->
#     document = jsdom code
#     emitter.emit "parsed", document
#   
#   if main.split("/").pop() isnt "app.html"
#     main += "/app.html"
#     
#   fs.readFile main, "utf8", (err, code) ->
#     throw "#{main} doesn't exist!" if err
#     emitter.emit "read", code
# 
# pullAssets = (document) ->
#   assets = {}
#   
#   assets["js"] = pullJavascript document
#   assets["css"] = pullCSS document
#   assets["images"] = pullImages document
#   assets["embeds"] = pullEmbeds document
#   
#   emitter.emit "pulled", assets
# 
pullEmbeds = (document) ->
  embeds = document.getElementsByTagName "embed"
  sources = []
  for embed in embeds
    sources.push embed.src
  
  return sources
# 
# pullImages = (document) ->
#   images = document.getElementsByTagName "img"
#   sources = []
#   for image in images
#     sources.push image.src
#   
#   return sources
# 
# pullJavascript = (document) ->
#   scripts = document.getElementsByTagName "script"
#   sources = []
#   for script in scripts
#     sources.push script.src
# 
#   return sources
# 
# pullCSS = (document) ->
#   stylesheets = document.getElementsByTagName "link"
#   sources = []
#   for stylesheet in stylesheets
#     sources.push stylesheet.href
#   
#   return sources
# 

module.exports = exports

