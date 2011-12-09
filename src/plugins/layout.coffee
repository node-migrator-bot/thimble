fs      = require "fs"
path    = require "path"

cheerio = require __dirname + "/../../node_modules/cheerio"

exports = module.exports = (layout) ->
  
  return (content, options, next) ->
    source = options.source
    fs.readFile layout, 'utf8', (err, html) ->
      next(err) if err
      
      $ = cheerio.load html
      # HACK: Load twice, so yield will always look like <yield />
      $ = cheerio.load $.html()
      
      # Find the basename of the source (flattener will handle rest)
      $include = $('<include>').attr('src', path.basename(source))
      
      # Replace yield with the include
      $('yield').replaceWith($include)

      next(null, $.html())
    
  
