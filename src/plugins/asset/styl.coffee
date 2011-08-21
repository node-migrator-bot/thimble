stylus = require "stylus"
_ = require "underscore"
path = require "path"
type = exports.type = "css"

render = exports.render = (content, file, options = {}, output) ->

  stylus(content)
    .set("filename", file)
    .render (err, css) ->
      throw err if err
      output null, css
  

module.exports = exports