stylus = require "stylus"

type = exports.type = "css"

render = exports.render = (content, file, output) ->
  stylus.render content, (err, css) ->
    throw err if err
    output css

module.exports = exports