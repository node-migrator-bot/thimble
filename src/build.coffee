
###
  builder.coffee --- Matt Mueller
  
  The purpose of builder.coffee is build our application for deployment
  
  builder moves and renders all the assets into a build.js and build.css
  also moving all the images into the public directory
  
  Finally it compiles all the html includes into one app.html
  
###

fs         = require "fs"
path       = require "path"
emitter    = new (require("events").EventEmitter)()

_          = require "underscore"
cheerio    = require "cheerio"

parser     = require "./renderer"
utils      = require "./utils"

build = exports.build = (app, options, callback) ->
  build = options.build = path.resolve options.build || "./build"
  root = options.root = path.resolve options.root || "./views"
  public = options.public = path.resolve options.public || "./public"
  env = options.env || "production"
  
  