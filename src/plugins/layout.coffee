fs      = require "fs"
path    = require "path"

cheerio = require 'cheerio'

exports = module.exports = (layout) ->
  
  return (content, options, next) ->
    fs.readFile layout, 'utf8', (err, html) ->
      next(err) if err

      $ = cheerio.load html
      # HACK: Load twice, so yield will always look like <yield />
      $ = cheerio.load $.html()
      
      # Replace yield with the include
      $('yield').replaceWith(content)
      next(null, $.html())
    
  
