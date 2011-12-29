fs      = require "fs"
path    = require "path"

cheerio = require 'cheerio'

exports = module.exports = (content, options, next) ->
  layoutPath = path.join options.root, options.layout

  fs.readFile layoutPath, 'utf8', (err, html) ->
    next(err) if err

    $ = cheerio.load html

    # Replace yield with the response content
    $('yield').replaceWith(content)

    next(null, $.html())
    
  
