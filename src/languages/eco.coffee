eco = require "eco"
path = require "path"
exports.type = "js"

compile = exports.compile = (content, file, options = {}, output) ->

  namespace = options.namespace or "window"
  template = options.template

  js = "#{namespace}.JST = #{namespace}.JST || {}; #{namespace}.JST['#{template}'] = " + eco.precompile content
  output null, js
  
module.exports = exports
