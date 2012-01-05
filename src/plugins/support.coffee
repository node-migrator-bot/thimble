
###
  This is for additional support files that need to be loaded.
###
fs = require 'fs'
path = require 'path'

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
      opts = file.options
      file = file.file
      
      # Set defaults
      opts.appendTo ||= 'head'
      opts.path ||= options['support path']
      
      extname = path.extname(file).substring 1

      if extname is 'js'
        tag = 'script'
      else if extname is 'css'
        tag = 'link'
      
      supportFile = opts.path + '/' + file

      fs.readFile supportFile, 'utf8', (err, str) ->
        return next(err) if err

        if !tag
          console.log "Cannot attach support file, " + file + ", not .js or .css"
        else
          # Attach the support file
          $asset = $('<' + tag + '>').text str
          $tag = $(opts.appendTo)
          if $tag.length
            $tag.append($asset)
          else
            $ = cheerio.load($asset.html() + '\n' + $.html())
        
        if finished()
          return next(null, $.html())
