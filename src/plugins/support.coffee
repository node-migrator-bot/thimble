###
  This is for additional support files that need to be loaded.
###
fs = require 'fs'
path = require 'path'

cheerio = require 'cheerio'

utils = require '../utils'

exports = module.exports = (opts = {}) ->
  opts.appendTo ||= 'head' 
  opts.path     ||= __dirname + '/../../support'
  
  return (content, options, next) ->
    files = []
  
    # Support specific options
    if options.support 
      files = options.support.files ||= []
  
    if files.length
      finished = utils.countdown files.length
    else
      return next(null, content)

    $ = cheerio.load(content)
      
    files.forEach (file) ->
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
          $tag = $('<' + tag + '>').text str
          $(opts.appendTo).append($tag.html())
        
        if finished()
          return next(null, $.html())
