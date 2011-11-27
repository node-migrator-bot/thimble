coffeescript = require "coffee-script"
_ = require "underscore"

type = exports.type = "js"

exports.compile = (content, file, options = {}, output) ->
  javascript = coffeescript.compile content
  output null, javascript
    
module.exports = exports