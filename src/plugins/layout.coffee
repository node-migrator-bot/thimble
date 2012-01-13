fs      = require "fs"
{join}    = require "path"

cheerio = require 'cheerio'

exports = module.exports = (options = {}) ->
  return layout

layout = exports.layout = (content, options, next) ->
  fs.readFile options.layout, 'utf8', (err, html) ->
    next(err) if err

    $ = cheerio.load html

    # Replace yield with the response content
    $('yield').replaceWith(content)

    next(null, $.html())
    
  
