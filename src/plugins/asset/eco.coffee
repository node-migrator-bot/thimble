eco = require "eco"
path = require "path"
exports.type = "js"

render = exports.render = (content, file, options = {}, output) ->
  template = path.basename file, path.extname(file)
  js = "window.JST = window.JST || {}; JST['#{template}'] = " + eco.precompile content

  output null, js
  
module.exports = exports
