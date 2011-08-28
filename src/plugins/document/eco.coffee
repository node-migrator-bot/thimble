eco = require "eco"
_ = require "underscore"

build = exports.build = (code, file, options = {}, output) ->

  if _.isFunction options
    output = options

  compiled = eco.precompile code
  # compiled = "module.exports = " + compiled
  
  output null, compiled

render = exports.render = (code, file, options = {}, output) ->
  if _.isFunction options
    output = options
    
  output null, do new Function "return #{eco.precompile code}"

module.exports = exports