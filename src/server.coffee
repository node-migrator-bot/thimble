###
  index.coffee --- Matt Mueller
  
  The purpose of this provide an application interface for developing applications.
  It has two main functions : middleware(appDir), and render(file)
  
  middleware - will load all the required assets
  render - will parse the html comments
  
###
path = require "path"
utils = require "./utils"

render = require('./render').render
middleware = require('./middleware').middleware

exports.boot = (server, options) ->
  root = options.root
  public = options.public ||= "./public"
  build = options.build ||= "./build"
  


  if !root
    throw "Need to specify a root directory"

  # Default settings for development and production
  server.configure ->
    # We're rolling our own layout, express's is not necessary
    server.set "view options", layout : false

  # Set view to root for development
  server.configure "development", ->
    server.set "views", root
    
    # Allow for a default or extension-less views - Must require only one. Could use a more express-compliant name
    # if options.extension
    #   server.set "view engine", options.extension
    
    server.use render("development", options)
    server.use middleware(root)

  # For production, set it to productionRoot
  server.configure "production", ->
    server.set "views", build
    server.set "view engine", "js"
    
    server.use (req, res, next) ->
      _render = res.render
      res.render = (view, options = {}, fn) ->
        res.render = _render
        options.layout = false
        return res.render(view, options, fn)
      next()
    
    server.register ".js", 
      compile : (str, options) ->
        # console.log str
        (locals) ->
          console.log str
          fn = do new Function "return " +  str
          return  fn(locals)
          # fn = new Function(str)
          # return fn(locals)

    # server.use (req, res, next) ->
    #   console.log 'hi'
    #   _render = res.render
    #   res.render = (view, options = {}) ->
    #     ext = path.extname view
    #     view = "./" + path.dirname(view) + "/" + path.basename(view, ext) + '.js'
    #     # view = productionRoot + "/" + view
    #     console.log view
    #     _render view, options
    #   
    #   next()
    


  

module.exports = exports
