coffeescript = require "coffee-script"

type = exports.type = "js"

render = exports.render = (content, file, output) ->
  javascript = coffeescript.compile content
  output null, javascript
    
module.exports = exports