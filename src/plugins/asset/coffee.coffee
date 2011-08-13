coffeescript = require "coffee-script"
_ = require "underscore"

type = exports.type = "js"

render = exports.render = (content, file, options = {}, output) ->
  
  if _.isFunction options
    output = options
  
  javascript = coffeescript.compile content
  output null, javascript
    
module.exports = exports