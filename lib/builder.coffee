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
  emitter = emitters[file] = new EventEmitter()
  public = exports.public = publicDir
  directory = exports.directory = path.dirname file
  
  emitter.once "read", (code) ->
    document = exports.document = jsdom(code)
    pull document, emitter
    
  emitter.once "pulled", (assets, elements) ->
    parse assets, elements, emitter
    
  emitter.once "built", () ->
    console.log "Successfully built #{file}"
    
  readFile file, emitter

parse = (assets, elements, emitter) ->
  document = exports.document
  finished = utils.countdown _.size(assets)

  # Pass in the actual elements themselves to replace the old elements. Have the parsers obtain the necessary src, href, etc. they need to read the files.
  
  # Returns false if nothing should be replaced. Otherwise { asset1 : content1, asset2 : content2, asset3 : content3 }
  # Content can either be a string or an object (jsdom DOMElement)

  callback = (err, output) ->
    throw err if err
    
    if output
      push output
    
    if finished()
      emitter.emit "built"
  
  for type of assets
    parser = require parserPath + "/#{type}.coffee"
    parser.build assets[type], public, callback


push = (content) ->
  document = exports.document
  if not document
    throw "No document found!"
  
pull = (document, emitter) ->
  elements = {} # {src : element}
  assets = {} # {type : [srcs]}
  
  for type, tag of assetTypes
    if _.isArray tag then [tag, attr] = tag else attr = "src"
    elems = document.getElementsByTagName tag
    sources = []
    for elem in elems
      source = elem[attr]
      source = exports.directory + "/" + source
      elements[source] = elem
      sources.push source
    
    if elems.length
      assets[type] = sources
      
  emitter.emit "pulled", assets, elements

readFile = (file, emitter) ->
  fs.readFile file, "utf8", (err, code) ->
    throw err if err
    
    emitter.emit "read", code

module.exports = exports

