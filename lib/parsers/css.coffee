build = exports.build = (assets, public, main, callback) ->
  bundler = require("./bundler.coffee")("build.css", public, main)
  bundler.bundle assets, callback
  
module.exports = exports