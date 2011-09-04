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
    server.use express.static root
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, opts = {}, fn) ->
        res.render = _render
        view = path.join root, view
        
        if opts.layout
          options.layout = path.resolve options.root + "/" + opts.layout
        
        builder.build view, options, (err, file) ->
          throw err if err
          opts.layout = false
          res.render file, opts, fn
          
      next()
        
    
  server.configure "production", ->
    server.use express.static public
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, opts = {}, fn) ->
        res.render = _render
        opts.layout = false
        res.render view, opts, fn
        
      next()
  
#   
#   
#   
#   # Default settings for development and production
#   server.configure ->
# 
#   # Set view to root for development
#   server.configure "development", ->
#     root = path.resolve(
#       options.root || 
#       server.set('views') || 
#       process.cwd() + "/views"
#     )
#     
#     server.set "views", root
#     
#     # Allow for a default or extension-less views - Must require only one. Could use a more express-compliant name
#     # if options.extension
#     server.set "view engine", options.extension
#     
#     server.use render("development", server, options)
#     server.use middleware(server, options)
# 
#   # For production, set it to productionRoot
#   server.configure "production", ->
#     server.set "views", build
#     server.set "view engine", "js"
#     
#     server.use (req, res, next) ->
#       _render = res.render
#       res.render = (view, options = {}, fn) ->
#         res.render = _render
#         options.layout = false
#         return res.render(view, options, fn)
#       next()
#     
#     server.register ".js", 
#       compile : (str, options) ->
#         (locals) ->
#           fn = do new Function "return " +  str
#           return  fn(locals)
# 
#     # server.use (req, res, next) ->
#     #   console.log 'hi'
#     #   _render = res.render
#     #   res.render = (view, options = {}) ->
#     #     ext = path.extname view
#     #     view = "./" + path.dirname(view) + "/" + path.basename(view, ext) + '.js'
#     #     # view = productionRoot + "/" + view
#     #     console.log view
#     #     _render view, options
#     #   
#     #   next()
#     
# 
# 
#   
# 
module.exports = exports
