
###
  Thimble.coffee boots the middleware
###

{normalize, extname, resolve} = require "path"
fs = require "fs"
parse = require('url').parse

express = require "express"

middleware = require "./middleware"
error = require "./error"

exports.start = (server) ->
  thimble = this
  options = thimble.settings
  
  # We're rolling our own layout, express's is not necessary
  server.set "view options", layout : false
  
  server.configure "production", ->
    err = null
    if !options.public
      err = error('no public directory')
      
    if !options.build
      err = error('no build directory')

    throw err if err  
    
  server.configure "development", ->
    if !options.root
      throw error('no root directory')
    
    server.set "views", resolve(options.root)
  
    stack = server.stack

    # Monkey-patch renderer at top of stack
    stack.unshift
      route  : ''
      handle : render.call(thimble, options)

    staticLayer = false
    for layer, i in server.stack
      if layer.handle and layer.handle.name is 'static'
        staticLayer = i
        break
    
    # Stack up middleware
    layers = []
    
    # Add the middleware
    layers.push
      route : ''
      handle : middleware(options)

    # Add the static overwrite
    layers.push
      route : ''
      handle : static(options)
      
    if staticLayer isnt false
      stack.splice.apply(stack, [staticLayer, 1].concat(layers))
    else
      server.stack = stack.concat layers

    # console.log server.stack[4].handle.toString()

###
  This will monkey-patch render to use thimble's
  renderer
###
render = exports.render = (options) ->
  thimble = this

  return (req, res, next) ->
    _render = res.render
    res.render = (view, locals = {}, fn) ->
      # Go back to old renderer after it passes through here once
      res.render = _render

      # Default to .html if no view extension given
      if !extname(view)
        view += ".html"

      thimble.render view, locals, (err, content) ->
        return next(err) if err
        res.send content
        
    # Be on your way.
    return next()
    
###
  This will overwrite how static does things
  
  Basically, prevent static from responding to .html files.
  
  Remember, res.render is monkey-patched in beginning, but
  doesn't get called till later on.
###
static = exports.static = (options) ->
  root = resolve options.root
  
  return (req, res, next) ->  
    url = parse req.url
    path = decodeURIComponent url.pathname
    
    if (normalize('/') == path[path.length - 1])
      return next()
    else
      # console.log req.url
      # console.log require('path').resolve options.root
      return express.static(root)(req, res, next)