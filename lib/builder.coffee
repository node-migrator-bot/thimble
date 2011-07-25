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

# Patch jsdom to work with certain html5 tags
jsdom = patcher.patch jsdom

assetTypes = 
  js : "script"
  css : ["link", "href"]
  images : "img"
  embeds : "embed"

class Builder
  
  constructor : (@file, @public, @options = {}) ->
    @directory = path.dirname file
    @emitter = new EventEmitter()
    
  build : (callback) ->
    emitter = @emitter
    
    emitter.once "read", (code) =>
      @document = jsdom code
      @pull @document, emitter
      
    emitter.once "pulled", (assets) =>      
      @parse assets, emitter
      
    emitter.once "parsed", (assets) =>
      @push assets, emitter
      
    emitter.once "built", =>
      callback null, @document.innerHTML
      
    @read @file
  
  read : (file) ->
    fs.readFile file, "utf8", (err, code) =>
      throw err if err
      @emitter.emit "read", code
      
  pull : (document) ->
    assets = {} 

    ### Assets
    {
      js : [
        DOMElement,
        ...
      ]

      css : [
        DOMElement,
        ...
      ]
    }

    ###

    for type, tag of assetTypes
      if _.isArray tag then [tag, attr] = tag else attr = "src"
      elems = document.getElementsByTagName tag

      continue if elems.length is 0

      elements = {}
      for elem in elems
        source = elem[attr]
        source = @directory + "/" + source
        elements[source] = elem

      assets[type] = elems

    @emitter.emit "pulled", assets
    
  parse : (assets) ->
    document = @document
    public = @public
    finished = utils.countdown _.size(assets)
  
    # Pass in the actual elements themselves to replace the old elements. Have the parsers obtain the necessary src, href, etc. they need to read the files.

    # Returns false if nothing should be replaced. Otherwise { asset1 : content1, asset2 : content2, asset3 : content3 }
    # Content can either be a string or an object (jsdom DOMElement)
    callback = (err, output) =>
      throw err if err

      if finished()
        @emitter.emit "built"

    for type of assets
      parser = require parserPath + "/#{type}.coffee"
      parser.build assets[type], public, @directory, callback
      

module.exports = (file, public, options) ->
  return new Builder file, public, options
