stylus = require "stylus"
_ = require "underscore"

type = exports.type = "css"

render = exports.render = (content, file, options = {}, output) ->

  stylus.render content, (err, css) ->
    throw err if err
    output null, css

module.exports = exports