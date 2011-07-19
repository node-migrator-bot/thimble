jsdom = require("jsdom").jsdom
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
fs = require "fs"
path = require "path"
pluginPath = "#{__dirname}/../plugins/"

build = exports.build = (main, public, options) ->

  emitter.once "read", (code) ->
    document = jsdom(code)
    pullAssets document
    
  emitter.once "pulled", (assets) ->
    buildAssets assets, main, public
    
  emitter.once "built", () ->
    console.log "Successfully built the files"
    
  read main
 
buildAssets = (assets, main, public) ->
  console.log "hi"

read = (main) ->
  emitter.once "read", (code) ->
    document = jsdom code
    emitter.emit "parsed", document
  
  if main.split("/").pop() isnt "app.html"
    main += "/app.html"
    
  fs.readFile main, "utf8", (err, code) ->
    throw "#{main} doesn't exist!" if err
    emitter.emit "read", code

pullAssets = (document) ->
  assets = {}
  
  assets["js"] = pullJavascript document
  assets["css"] = pullCSS document
  assets["images"] = pullImages document
  assets["embeds"] = pullEmbeds document
  
  emitter.emit "pulled", assets

pullEmbeds = (document) ->
  embeds = document.getElementsByTagName "embed"
  sources = []
  for embed in embeds
    sources.push embed.src
  
  return sources

pullImages = (document) ->
  images = document.getElementsByTagName "img"
  sources = []
  for image in images
    sources.push image.src
  
  return sources

pullJavascript = (document) ->
  scripts = document.getElementsByTagName "script"
  sources = []
  for script in scripts
    sources.push script.src

  return sources

pullCSS = (document) ->
  stylesheets = document.getElementsByTagName "link"
  sources = []
  for stylesheet in stylesheets
    sources.push stylesheet.href
  
  return sources


module.exports = exports

