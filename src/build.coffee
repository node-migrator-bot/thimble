
###
  builder.coffee --- Matt Mueller
  
  The purpose of builder.coffee is build our application for deployment
  
  builder moves and renders all the assets into a build.js and build.css
  also moving all the images into the public directory
  
  Finally it compiles all the html includes into one app.html
  
###

fs         = require "fs"
path       = require "path"

cheerio    = require "cheerio"

flatten    = require "./flatten"
utils      = require "./utils"

build = exports.build = (app, options, callback) ->
  build = options.build = path.resolve options.build || "./build"
  root = options.root = path.resolve options.root || "./views"
  public = options.public = path.resolve options.public || "./public"
  env = options.env || "production"

  utils.readFile app, (err, code) ->
    flatten.flatten code, path.dirname(app), options, (err, code) ->
      throw err if err

module.exports = exports

build "../test/files/index.html", {}, (err, $) ->
  throw err if err
  console.log $.html()
  
