###
  builder.coffee --- Matt Mueller
  
  The purpose of builder.coffee is build our application for deployment
  
  builder moves and renders all the assets into a build.js and build.css
  also moving all the images into the public directory
  
  Finally it compiles all the html includes into one app.html
  
###
fs           = require "fs"
path         = require "path"
emitter      = new (require("events").EventEmitter)()

parser = require "./parser"
{countdown, hideTemplateTags, unhideTemplateTags} = require "./utils"
_            = require "underscore"
jsdom        = require "jsdom"
patch      = require "./patcher"
$         = require "jquery"
assetTypes = require("./tags/tags").types
plugins = require("./plugin")("./plugins/document")

# Patch jsdom to work with certain html5 tags
jsdom = patch(jsdom).jsdom

build = exports.build = (app, public, options, callback) ->
  appDir = path.dirname app

  emitter.once "parsed", (html) ->
    # jsdom cannot handle ERB <% ... %> style tags, so we escape
    html = hideTemplateTags html
    bundle html, appDir, public
    
  # Bundle all the STATIC assets, dynamic assets cannot be bundled before runtime. CASE CLOSED.
  emitter.once "bundled", (html) ->
    # unhide escaped ERB <% ... %> style tags
    html = unhideTemplateTags html
    compile html, app, options
  
  emitter.once "compiled", (code) ->
    write code, public + "/app.js"
      
  emitter.once "written", ->
    callback null
      
  parser.parse app, options, (err, code) ->
    throw err if err
    emitter.emit "parsed", code

# Pull in all the assets and parse them, manipulates HTML document if necessary (ie. build.js, build.css)
bundle = (html, appDir, public) ->
  document = jsdom html
  finished = countdown _.size(assetTypes)

  # When finished, this is called
  done = () ->
    doctype = if document.doctype then document.doctype else ""
    html = doctype + document.innerHTML
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
    
    assetHandler = require "./tags/#{type}"
    assetHandler.build elements, public, appDir, callback
  
# This will compile the template with the plugin of your choosing
compile = (html, app, options) ->
  plugin = plugins app
  
  if !plugin
    ext = path.extname app
    err = "Couldn't find plugin(#{ext}) for #{file}"
    callback err
    
  plugin.build html, app, options, (err, code) ->
    throw err if err
    emitter.emit "compiled", code

write = (code, file) ->
  fs.writeFile file, code, "utf8", (err) ->
    throw err if err
    emitter.emit "written"

module.exports = exports
