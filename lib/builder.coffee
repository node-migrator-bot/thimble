jsdom = require("jsdom").jsdom
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
fs = require "fs"
path = require "path"
pluginPath = "#{__dirname}/../plugins/"

# Load the plugins
files = fs.readdirSync pluginPath
plugins = {}

for file in files
  fileArr = file.split "."
  fileArr.pop()
  ext = fileArr.join "."
  plugins[ext] = file

build = exports.build = (main, options) ->

  emitter.once "read", (code) ->
    document = jsdom(code)
    scripts = pullJavascript document
    stylesheets = pullCSS document
    images = pullImages document
    
    console.log images
    console.log scripts
    console.log stylesheets
    
  if main.split("/").pop() is not "app.html"
    main += "/app.html"

  fs.readFile main, "utf8", (err, code) ->
    throw "#{main} doesn't exist!" if err
    emitter.emit "read", code

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

