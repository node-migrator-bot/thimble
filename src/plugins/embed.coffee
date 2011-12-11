###
  Embed.coffee - Used to embed templates into the document
###

cheerio = require "cheerio"

exports = module.exports = () ->
  
  return (content, options, next) ->
    
    $ = cheerio.load content
    
    $('script[type=text/template]').each ->
      $script = $(this)
      
      console.log $script.attr('src')