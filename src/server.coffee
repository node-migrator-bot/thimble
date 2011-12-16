
###
  Thimble.coffee boots the middleware
###

path = require "path"
fs = require "fs"

express = require "express"

middleware = require "./middleware"

exports.boot = (server) ->
  thim = this
  options = thim.settings
  root = options.root 
  
  # We're rolling our own layout, express's is not necessary
  server.set "view options", layout : false
  server.set "views", root

  server.configure "development", ->
  
    # Use our middleware to catch custom asset types
    server.use middleware options
    
    # Add on custom middleware to monkey-patch render
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, locals = {}, fn) ->
        res.render = _render
        
        # Add .html if no view extension given
        if !path.extname(view)
          view += ".html"
        
        view = path.join root, view

        thim.render view, locals, (err, content) ->
          throw err if err
          res.send content
      
      if path.extname req.url is ".html"
        # If our request is an html file, don't use static module
        return next()
      else
        # Otherwise we should use it
        express.static(root) req, res, (err) ->
          return next(err)
