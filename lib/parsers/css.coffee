build = exports.build = (assets, public, callback) ->
  bundler = require("./bundler.coffee")("build.css")
  bundler.bundle assets, public, callback
  
module.exports = exports