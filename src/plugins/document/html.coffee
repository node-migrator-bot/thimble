_ = require "underscore"

build = exports.build = (code, file, options = {}, output) ->

  if _.isFunction options
    output = options

  c = _.templateSettings
  tmpl = "module.exports=function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};" + "with(obj||{}){__p.push('" + str.replace(/\\/g, "\\\\").replace(/'/g, "\\'").replace(c.interpolate, (match, code) ->
      "'," + code.replace(/\\'/g, "'") + ",'"
    ).replace(c.evaluate or null, (match, code) ->
      "');" + code.replace(/\\'/g, "'").replace(/[\r\n\t]/g, " ") + "__p.push('"
    ).replace(/\r/g, "\\r").replace(/\n/g, "\\n").replace(/\t/g, "\\t") + "');}return __p.join('');}"

  output null, tmpl

render = exports.render = (code, file, options = {}, output) ->
  output null, _.template code
  
module.exports = exports