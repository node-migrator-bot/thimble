handlebars = require "handlebars"

type = exports.type = "js"

exports.compile = (content, file, options = {}, output) ->
  namespace = options.namespace or "window"
  template = options.template

  compiled = handlebars.precompile content

  js = "#{namespace}.JST = #{namespace}.JST || {}; #{namespace}.JST['#{template}'] = " + compiled
  output null, js
    
module.exports = exports