build = exports.build = (assets, public, main, callback) ->
  bundler = require("./bundler.coffee")("build.js", public, main)
  bundler.bundle assets, callback

module.exports = exports
  