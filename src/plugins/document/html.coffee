_ = require "underscore"

build = exports.build = (content, file, options = {}, output) ->

  if _.isFunction options
    output = options

  rendered = _.template content
  output null, rendered

module.exports = exports