###
  builder.coffee --- Matt Mueller
  
  The purpose of builder.coffee is build our application for deployment
  
  builder moves and renders all the assets into a build.js and build.css
  also moving all the images into the public directory
  
  Finally it compiles all the html includes into one app.html
  
###

EventEmitter = require("events").EventEmitter
_            = require "underscore"
emitters     = {}
fs           = require "fs"
path         = require "path"
jsdom        = require "jsdom"
patch      = require "./patcher"
utils        = require "./utils"

# Patch jsdom to work with certain html5 tags
# jsdom = patcher.patch jsdom
jsdom = patch(jsdom).jsdom
$ = require "jquery"

assetTypes = require("./tags/tags").types

class Builder
  
  constructor : (@file, @public, @options = {}) ->
    @directory = path.dirname file
    @emitter = new EventEmitter()

  build : (output) ->
    emitter = @emitter

    emitter.once "read", (html) =>
      @flatten html, emitter
      
    emitter.once "flattened", (html) =>
      @bundle html, emitter
          
    emitter.once "bundled", (html) =>
      @compile html, @file, emitter
    
    emitter.once "compiled", (html) =>
      output null, html

    @read @file
  
  read : (file) ->
    fs.readFile file, "utf8", (err, code) =>
      throw err if err
      @emitter.emit "read", code
  
  # Flatten code by finding all the embeds and replacing them
  flatten : (html, emitter) ->
    commentParser = require "./plugins/document/comments"
    
    options = {}
    options.outer = @options.outer if @options.outer
    
    commentParser.render html, @file, options, (html) ->
      emitter.emit "flattened", html
  
  # Pull in all the assets and parse them, manipulates HTML document if necessary (ie. build.js, build.css)
  bundle : (html, emitter) ->
    document = jsdom html
    finished = utils.countdown _.size(assetTypes)

    # When finished, this is called
    done = () ->
      html = document.doctype + document.innerHTML
      emitter.emit "bundled", html
      
    callback = (err) =>
      throw err if err
      if finished()
        done()
    
    for type, tag of assetTypes
      elements = $(tag, document).get()
      if elements.length is 0
        if finished()
          done()
          return
        else
          continue
      
      parser = require "./tags/#{type}"
      parser.build elements, @public, @directory, callback
  
  # This will compile the template with the plugin of your choosing
  compile : (html, file, emitter) ->
    plugin = require("./plugin")("./plugins/document")
    
    output = (err, html) ->
      throw err if err
      emitter.emit "compiled", html
      
    options = {}
    
    Plugin = plugin file
    if Plugin
      Plugin.build html, file, options, output
    
  
module.exports = Builder
