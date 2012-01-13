fs      = require "fs"
{join}    = require "path"

cheerio = require 'cheerio'

{read} = require '../utils'

exports = module.exports = (options = {}) ->
  return layout

layout = exports.layout = (content, options, next) ->
  if(!options.layout)
    return next(null, content);
    
  read options.layout, (err, html) ->
    next(err) if err

    $ = cheerio.load html

    # Replace yield with the response content
    $('yield').replaceWith(content)

    next(null, $.html())
    
  
