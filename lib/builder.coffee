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

$ = require "jquery"

assetTypes = 
  js : "script"
  css : "link"
  images : "img"

class Builder
  
  constructor : (@file, @public, @options = {}) ->
    @directory = path.dirname file
    @emitter = new EventEmitter()
    @root = if options.root then file else false    

  build : (callback) ->
    emitter = @emitter
    
    emitter.once "read", (code) =>
      cb = (document) =>
        @document = document
        emitter.emit "flattened"
        
      document = jsdom code
      
      @flatten document, @directory, cb
      
    emitter.once "flattened", () =>
      @bundle emitter
    
    emitter.once "bundled", ()->
      emitter.emit "built"
    
    emitter.once "built", =>
      callback null, @document.innerHTML
      
    @read @file
  
  read : (file) ->
    fs.readFile file, "utf8", (err, code) =>
      throw err if err
      @emitter.emit "read", code
  
  # Flatten code by finding all the embeds and replacing them
  flatten : (document, directory, callback) ->
    builder = this
    parser = require(parserPath + "/comments.coffee")(document.innerHTML)
    
    embeds = $("embed", document)
    
    callback(document) if embeds.size() is 0
    finished = utils.countdown embeds.size()

    embeds.each ->
      embed = this
      file = directory + "/" + embed.src

      fs.readFile file, "utf8", (err, contents) ->
        throw err if err
        
        documentFragment = jsdom(contents)
        builder.fixPaths documentFragment, path.dirname(embed.src)

        output = (fragment) ->
          $(embed).replaceWith(fragment.innerHTML)
          if finished()
            callback(document)
            
        builder.flatten documentFragment, path.dirname(file), output
  
  fixPaths : (document, path) ->
    
    for type, tag of assetTypes
      attribute = if type is "css" then "href" else "src"
      
      $(tag, document).each (i, element) ->
        $(element).attr(attribute, path + "/" + element[attribute])
  
  # Pull in all the assets and parse them
  bundle : (emitter) ->
    document = @document
    finished = utils.countdown _.size(assetTypes)
    
    callback = (err) =>
      throw err if err
      
      if finished()
        emitter.emit "bundled"
    
    for type, tag of assetTypes
      elements = $(tag, document).get()
      
      if elements.length is 0
        if finished()
          emitter.emit "bundled"
          return
        else
          continue
      
      parser = require parserPath + "/#{type}.coffee"
      parser.build elements, @public, @directory, callback
    
  #   
  # parse : (assets) ->
  #   document = @document
  #   public = @public
  #   finished = utils.countdown _.size(assets)
  # 
  #   
  # 
  #   # Pass in the actual elements themselves to replace the old elements. Have the parsers obtain the necessary src, href, etc. they need to read the files.
  # 
  #   # Returns false if nothing should be replaced. Otherwise { asset1 : content1, asset2 : content2, asset3 : content3 }
  #   # Content can either be a string or an object (jsdom DOMElement)
  #   callback = (err, output) =>
  #     throw err if err
  # 
  #     if finished()
  #       @emitter.emit "parsed"
  # 
  #   for type of assets
  #     parser = require parserPath + "/#{type}.coffee"
  #     parser.build assets[type], public, @directory, callback
  # 
  # bundle : (emitter) ->
  #   finished = utils.countdown 2
  #   stylesheets = _.uniq Builder.stylesheets
  #   scripts = _.uniq Builder.scripts
  # 
  #   bundler = require("#{lib}/parsers/bundler.coffee")
  #   bundler("build.css", @public, @directory).bundle stylesheets, () ->
  #     console.log "ok"
      

# Global arrays to hold stylesheets and scripts
Builder.stylesheets = []
Builder.scripts = []

module.exports = Builder
