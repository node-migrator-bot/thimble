_ = require "underscore"

render = exports.render = (content, file, options = {}, output) ->

  if _.isFunction options
    output = options

  rendered = _.template content
  output null, rendered

module.exports = exports