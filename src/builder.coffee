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
utils = require "./utils"
_            = require "underscore"
jsdom        = require "jsdom"
patch      = require "./patcher"
$         = require "jquery"
assetTypes = require("./tags/tags").types
plugins = require("./plugin")("./plugins/document")

# Patch jsdom to work with certain html5 tags
jsdom = patch(jsdom).jsdom

exports.build = (app, options = {}, callback) ->
  build = options.build = path.resolve options.build || "./build"
  root = options.root = path.resolve options.root || "./views"
  public = options.public = path.resolve options.public || "./public"

  emitter.once "parsed", (html) ->
    # jsdom cannot handle ERB <% ... %> style tags, so we escape them
    html = utils.hideTemplateTags html
    bundle html, options
    
  # Bundle all the STATIC assets, dynamic assets cannot be bundled before runtime. CASE CLOSED.
  emitter.once "bundled", (code) ->
    # unhide escaped ERB <% ... %> style tags
    code = utils.unhideTemplateTags code
    
    # Synchronously makes all the directories it's missing
    utils.mkdir build
    
    # Write the code to app.js
    write code, build + "/" + path.basename(app)
      
  emitter.once "written", (file) ->
    return callback null, file
      
  parser.parse app, options, (err, code) ->
    throw err if err
    emitter.emit "parsed", code

# Pull in all the assets and parse them, manipulates HTML document if necessary (ie. build.js, build.css)
bundle = (html, options) ->
  document = jsdom html
  finished = utils.countdown _.size(assetTypes)

  # Make the dir just in case it's not already there
  utils.mkdir options.public

  # When finished, this is called
  done = () ->
    doctype = if document.doctype then document.doctype else ""
    html = doctype + document.innerHTML
    emitter.emit "bundled", html
    
  callback = (err) =>
    throw err if err
    if finished()
      done()
  
  # Remove ALL classes that are named "thimble-test"
  if options.env is "production"
    $(".thimble-test", document).remove()
  
  for type, tag of assetTypes
    tag = [tag] if not _.isArray(tag)
    tag = tag.join ","
    elements = $(tag, document).get()
    if elements.length is 0
      if finished()
        done()
        return
      else
        continue
    
    assetHandler = require "./tags/#{type}"
    assetHandler.build elements, options, callback
  
# This will compile the template with the plugin of your choosing
compile = (html, app, options) ->
  plugin = plugins app
  
  if !plugin
    ext = path.extname app
    err = "Couldn't find plugin(#{ext}) for #{file}"
    callback err
    
  code = plugin.compile html, options
  
  emitter.emit "compiled", code

write = (code, file) ->
  fs.writeFile file, code, "utf8", (err) ->
    throw err if err
    emitter.emit "written", file




module.exports = exports
