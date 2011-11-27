stylus = require "stylus"
_ = require "underscore"
path = require "path"
type = exports.type = "css"

compile = exports.compile = (content, file, options = {}, output) ->

  styl = stylus(content)
  
  try
    nib = require "nib"
    styl.use(nib())
  catch error
    # Do nothing
  
  styl
    .set("filename", file)
    .include(options.root)
    .render (err, css) ->
      throw err if err
      output null, css
  

module.exports = exports