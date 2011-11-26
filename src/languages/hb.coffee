handlebars = require "handlebars"

type = exports.type = "js"

exports.compile = (content, file, options = {}, output) ->
  javascript = handlebars.compile content
  output null, javascript
    
module.exports = exports