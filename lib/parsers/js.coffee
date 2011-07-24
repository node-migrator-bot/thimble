build = exports.build = (assets, public, main, callback) ->
  bundler = require("./bundler.coffee")("build.js")
  bundler.bundle assets, public, main, callback

module.exports = exports
  