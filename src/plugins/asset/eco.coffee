eco = require "eco"
path = require "path"
exports.type = "js"

render = exports.render = (content, file, options = {}, output) ->

  namespace = options.namespace or "window"
    
  template = path.basename file, path.extname(file)
  js = "#{namespace}.JST = #{namespace}.JST || {}; #{namespace}.JST['#{template}'] = " + eco.precompile content

  output null, js
  
module.exports = exports
