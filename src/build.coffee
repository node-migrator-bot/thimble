
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

  html = fs.readFileSync app

  flatten html, path.dirname(app), options, (err, code) ->
    throw err if err
    console.log code

flatten = exports.flatten = (html, directory, options, callback) ->
  $ = cheerio.load html
  
  $includes = $('include')
  numIncludes = $includes.length
  
  if numIncludes is 0
    return callback null, html
    
  finished = utils.countdown numIncludes
  $includes.each ->
    $this = $(this)
    src = $this.attr('src')
    
    if !src and finished()
      return callback null, $.html()

    if src[0] is "/"
      filePath = options.root + "/" + src
    else
      filePath = directory + "/" + src
   
    utils.readFile filePath, (err, code) ->
      $this.before(code)
      $this.remove()
      
      if finished()
        return callback null, $.html()

fixPaths = ($) ->
  

build "../test/index.html", {}, (err, html) ->
  throw err if err
  
  # console.log html
  
  
