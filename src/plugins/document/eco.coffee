eco = require "eco"
_ = require "underscore"

render = exports.render = (content, file, options = {}, output) ->

  if _.isFunction options
    output = options

  output null, eco.precompile(content)

module.exports = exports