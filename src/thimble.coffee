
###
  Main Server
###

###
  index.coffee --- Matt Mueller
  
  The purpose of this provide an application interface for developing applications.
  It has two main functions : middleware(appDir), and render(file)
  
  middleware - will load all the required assets
  render - will parse the html comments
  
###
path = require "path"
utils = require "./utils"
express = require "express"
# render = require('./render').render
middleware = require('./middleware').middleware
builder = require("./builder")
plugin = require("./plugin")("plugins/document")

exports.boot = (server, options = {}) ->
  build = options.build = path.resolve options.build || "./build"
  public = options.public = path.resolve options.public || "./public"
  root = options.root = path.resolve options.root || "./views"
  env = options.env = process.env.NODE_ENV || "development"

  # We're rolling our own layout, express's is not necessary
  server.set "view options", layout : false
  server.set "views", build
  
  # Register the available document plugins
  for extension, compiler of plugin.extensions
    server.register extension, require(compiler)
  
  server.configure "development", ->
    server.use middleware root, options
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, opts = {}, fn) ->
        res.render = _render
        
        view = path.join root, view
        
        if opts.layout
          options.layout = path.resolve options.root + "/" + opts.layout
          # Overwrite express's layout
          opts.layout = false
          
        builder.build view, options, (err, file) ->
          console.log err.message if err
          res.render file, opts, fn
          
      
      if path.extname req.url is ".html"
        next()
      else
        server.use express.static root
        return next()
        
    
  server.configure "production", ->
    server.use express.static public
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, opts = {}, fn) ->
        res.render = _render
        opts.layout = false
        res.render view, opts, fn
        
      next()
  

module.exports = exports