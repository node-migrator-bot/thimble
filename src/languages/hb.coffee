handlebars = require "handlebars"

type = exports.type = "js"

exports.compile = (content, file, options = {}, output) ->
  console.log "handlebars not yet implemented"
  output null, ""
  # javascript = handlebars.precompile content
  #   output null, javascript
    
module.exports = exports