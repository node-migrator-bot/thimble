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
  css : ["link", "href"]
  images : "img"
  embeds : "embed"

class Builder
  
  constructor : (@file, @public, @options = {}) ->
    @directory = path.dirname file
    @emitter = new EventEmitter()
    @root = if options.root then file else false    

  build : (callback) ->
    emitter = @emitter
    
    emitter.once "read", (code) =>
      @document = jsdom code
      callback = (document) =>
        
        # emitter.emit "pulled"

      @pull code, @directory, callback
      
    emitter.once "pulled", (assets) =>      
      @parse assets, emitter
      
    emitter.once "parsed", (assets) =>
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
  
  # Pull in all the embeds and replace them
  pull : (code, directory, callback) ->
    builder = this
    document = jsdom code
    embeds = $("embed", document)
    
    callback(document) if embeds.size() is 0
    finished = utils.countdown embeds.size()

    embeds.each ->
      embed = this
      file = directory + "/" + embed.src

      fs.readFile file, "utf8", (err, contents) ->
        throw err if err

        output = (fragment) ->
          $(embed).replaceWith(fragment.innerHTML)
          if finished()
            callback(document)
            
        builder.pull contents, path.dirname(file), output
    
    
    # $("embed", document).each ->
    #   embed = this
    #   file = directory + "/" + embed.src
    # 
    #   fs.readFile file, "utf8", (err, code) ->
    #     throw err if err
    #     
    #     pull jsdom(code), path.dirname(file), 

        
    
    # for type, tag of assetTypes
    #       if _.isArray tag then [tag, attr] = tag else attr = "src"
    #       elems = document.getElementsByTagName tag
    # 
    #       continue if elems.length is 0
    # 
    #       elements = {}
    #       for elem in elems
    #         source = elem[attr]
    #         source = @directory + "/" + source
    #         elements[source] = elem
    #         
    #         if type is "css"
    #           Builder.stylesheets.push source
    #         else if type is "js"
    #           Builder.scripts.push source
    # 
    #       assets[type] = elems
    # 
    #     @emitter.emit "pulled", assets
    
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
        @emitter.emit "parsed"

    for type of assets
      parser = require parserPath + "/#{type}.coffee"
      parser.build assets[type], public, @directory, callback

  bundle : (emitter) ->
    finished = utils.countdown 2
    stylesheets = _.uniq Builder.stylesheets
    scripts = _.uniq Builder.scripts

    bundler = require("#{lib}/parsers/bundler.coffee")
    bundler("build.css", @public, @directory).bundle stylesheets, () ->
      console.log "ok"
      

# Global arrays to hold stylesheets and scripts
Builder.stylesheets = []
Builder.scripts = []

module.exports = Builder
