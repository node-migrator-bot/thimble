###
  index.coffee --- Matt Mueller
  
  The purpose of this provide an application interface for developing applications.
  It has two main functions : middleware(appDir), and render(file)
  
  middleware - will load all the required assets
  render - will parse the html comments
  
###
path = require "path"
{toKeys} = require "./utils"

render = require('./render').render
middleware = require('./middleware').middleware

exports.boot = (app, options) ->
  {root, productionRoot, extensions} = options
  root ||= "./ui"
  extensions ||= ["tm"]
  productionRoot ||= "./public"
  extensions = toKeys extensions

  # Set view to root for development
  app.configure "development", ->
    app.set "views", root
    app.use (req, res, next) ->
      res.render = (view, options = {}) ->
        if extensions[path.extname(view).substring(1)] isnt undefined
          options.root = root
          options.layout = root + "/" + options.layout if options.layout
          render root + "/" + view, options, (err, html) ->
            throw err if err
            res.send html
        
      next()
      
    app.use middleware(root)
    
  # For production, set it to productionRoot
  app.configure "production", ->
    app.set "views", productionRoot
    
    # app.register ".js", 
    #   compile : (str, options) ->
    #     (locals)
    #   
    # app.register ".html", 
    #   compile : (str, options) ->
    #     (locals) ->
    #       _.template str, locals

  

module.exports = exports
