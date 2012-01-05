
###
  This is for additional support files that need to be loaded.
###
fs = require 'fs'
{extname, join} = require 'path'

cheerio = require 'cheerio'

utils = require '../utils'

exports = module.exports = (content, options, next) ->
    # console.log 'this', this
    files = options['support files']
    
    if files.length
      finished = utils.after files.length
    else
      return next(null, content)

    $ = cheerio.load(content)

    files.forEach (file) ->
      # Explode object
      if file.name
        name = file.name
        appendTo = file.appendTo || 'head'
        path = file.path || options['support path']
      else
        name = file
        appendTo = 'head'
        path = options['support path']

      ext = extname(name).substring 1
      
      if ext is 'js'
        tag = 'script'
      else if ext is 'css'
        tag = 'link'
      
      supportFile = join(path, name)

      fs.readFile supportFile, 'utf8', (err, str) ->
        return next(err) if err

        if tag
          # Attach the support file
          $asset = $('<' + tag + '>').text str
          $tag = $(appendTo)
          if $tag.length
            $tag.append($asset)
          else
            $ = cheerio.load($asset.html() + '\n' + $.html())
        
        if finished()
          return next(null, $.html())
