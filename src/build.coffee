
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
  
  emitter.once "read", (err, code) ->
    $ = cheerio.load code
    
    $("include").each ->
      self = this
      src = $(this).attr('src')
      if src
        test = path.dirname app
        fs.readFile test + "/" + src, "utf8", (err, html) ->
          # console.log html
          # console.log $(self).before
          $(self).before(html)
          $(self).remove()
          
          console.log $.html()
          
  
  read app

read = exports.read = (file) ->
  
  fs.readFile file, "utf8", (err, code) ->
    emitter.emit "read", err, code 

build "../test/index.html", {}, (err, html) ->
  throw err if err
  
  console.log html
  
  
