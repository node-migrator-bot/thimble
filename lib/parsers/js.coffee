build = exports.build = (assets, public, callback) ->
  bundler = require("./bundler.coffee")("build.js")
  bundler.bundle assets, public, callback

module.exports = exports
  