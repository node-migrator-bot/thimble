# Needs a new version of less to work with the new node.

less = require "less"

exports.compile = (content, file, options = {}, output) ->
  less.render content, (err, css) ->
    output err, css
  
module.exports = exports