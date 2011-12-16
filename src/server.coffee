
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
       
    # Inject our middleware where static was
    injected = false
    server.stack.forEach (layer, i) ->
      if layer.handle and layer.handle.name is 'static'
        server.stack[i] = 
          route : ''
          handle : middleware(options)
        injected = true

    # If static didn't exist, just append to end
    if !injected
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
      
      # If our request is an html file, don't use static module
      if path.extname req.url is ".html"
        return next()
      else
        # Otherwise we should use it
        express.static(root)(req, res, next)
