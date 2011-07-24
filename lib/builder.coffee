EventEmitter = require("events").EventEmitter
_ = require "underscore"
emitters = {}
fs = require "fs"
path = require "path"
lib = __dirname
jsdom = require "jsdom"
patcher = require lib + "/patcher.coffee"
parserPath = lib + "/parsers"
utils = require lib + "/utils.coffee"

# Patch jsdom to work with html5 tags
jsdom = patcher.patch jsdom

assetTypes = 
  js : "script"
  css : ["link", "href"]
  images : "img"
  embeds : "embed"

build = exports.build = (file, publicDir, options = {}) ->
  fileDir = path.dirname file
  emitter = emitters[file] = new EventEmitter()
  public = exports.public = publicDir
  
  emitter.once "read", (code) ->
    document = exports.document = jsdom(code)
    pullAssets fileDir, emitter
    
  emitter.once "pulled", (assets) ->
    console.log assets
    parseAssets assets, emitter
    
  emitter.once "built", () ->
    console.log "Successfully built the files"
    
  readFile file, emitter

parseAssets = (assets, elements, emitter) ->
  public = exports.public
  document = exports.document
  
  types = _.keys assets
  finished = utils.countdown types.length

  # ** All assets get bundled together so maybe we can just build the whole js and css files, then move all the assets together
  # -- Return null if success, true if failure **
  
  callback = (err, asset, content) ->
    throw err if err
    
    if content
      push content
    
    if finished()
      emitter.emit "built"
  
  for type in types
    parser = require parserPath + "/#{type}.coffee"
    parser.build assets[type], public, callback


push = (content) ->
  document = exports.document
  if not document
    throw "No document found!"
  
  

pullAssets = (fileDir, emitter) ->
  document = exports.document
  assets = {}
  elements = {}
  
  for type, tag of assetTypes
    if _.isArray tag then [tag, attr] = tag else attr = "src"
    [assets[type], elems] = pullAssetType document, tag, attr
    elements = _.extend elements, elems

  console.log elements
  
  # Remove empty objects
  assets = removeEmpties assets
  
  # Makes all the links absolute
  assets = makeAbsolute fileDir, assets

  emitter.emit "pulled", assets

pullAssetType = (document, tag, attr = "src") ->
  tags = document.getElementsByTagName tag

  sources = []
  elements = {}
  
  for t in tags
    sources.push t[attr]
    # Add to global sources
    elements[t[attr]] = t
    
  return [sources, elements]

getElementBySrc = (source) ->
  if _sources[source] then _sources[source] else null

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
# pullEmbeds = (document) ->
#   embeds = document.getElementsByTagName "embed"
#   sources = []
#   for embed in embeds
#     sources.push embed.src
#   
#   return sources
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

