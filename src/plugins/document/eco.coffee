eco = require "eco"
_ = require "underscore"

build = exports.build = (content, file, options = {}, output) ->

  if _.isFunction options
    output = options

  compiled = eco.precompile content
  
  compiled = "module.exports = " + compiled
  
  output null, compiled

module.exports = exports