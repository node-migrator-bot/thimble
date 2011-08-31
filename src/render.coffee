# Used to render a thimble template

path = require "path"
fs = require "fs"
parse = require("./parser").parse
plugins = require("./plugin")("./plugins/document")

render = exports.render = (environment, options) ->
  root = options.root
  build = options.build

  switch environment
    when "development"
      renderForDevelopment options
    when "production"
      renderForProduction options 

renderForDevelopment = (options) ->
  root = options.root
  renderCached = false
  
  # Return middleware
  (req, res, next) ->
  
    # Caching currently not working correctly.. disabled for now.
    # if renderCached
    #   res.render = renderCached
    #   return next()
    # Monkey patch res.render
    res.render = (view, locals) ->
      if locals.layout
        options.layout = root + "/" + locals.layout

      view = root + "/" + view
      parse view, options, (err, code) ->
        plugin = plugins view
        
        if !plugin
          ext = path.extname app
          throw "Couldn't find plugin(#{ext}) for #{app}"

        plugin.render code, view, locals, (err, template) ->
          return res.send template(locals)
          
    renderCached = res.render;
    next()
          
# renderForProduction = (options) ->
#   build = options.build
#   renderCached = false
#   
#   # Return middleware
#   (req, res, next) ->
#     if renderCached
#       res.render = renderCached
#       return next()
#       
#     ren = res.render
#     res.render = (view, locals) ->
#       view = build + "/" + view
#       console.log view
#       console.log ren
#       console.log 'ok'
#       ren(view, locals)
#     
#     renderCached = res.render
#     return next()
#     
    