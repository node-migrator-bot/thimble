eco = require "eco"
_ = require "underscore"

build = exports.build = (content, file, options = {}, output) ->

  if _.isFunction options
    output = options

  output null, eco.precompile(content)

module.exports = exports