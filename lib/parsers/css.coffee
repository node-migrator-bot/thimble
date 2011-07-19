lib = "#{__dirname}/.."

build = exports.build = (assets, public, callback) ->
  bundler = require("#{lib}/bundler.coffee")("build.css")
  bundler.bundle assets, public, callback
  
module.exports = exports