
###
  This is for additional support files that need to be loaded.
###
fs = require 'fs'
{extname, join} = require 'path'

cheerio = require 'cheerio'
_ = require 'underscore'

utils = require '../utils'

###
  Public: Add support files to our response
###
exports = module.exports = (options = {}) ->
  return support

support = exports.support = (content, options, next) ->
  files = options.support
  
  if files.length
    files = _.uniq(files)
    finished = utils.after files.length
  else
    return next(null, content)

  $ = cheerio.load(content)

  files.forEach (file) ->
    # Explode object
    supportFile = file.file
    appendTo = file.appendTo || 'head'

    ext = extname(supportFile).substring 1
    
    if ext is 'js'
      tag = 'script'
    else if ext is 'css'
      tag = 'link'

    fs.readFile supportFile, 'utf8', (err, str) ->
      return next(err) if err

      if tag
        # Attach the support file
        $asset = $('<' + tag + '>')
          .addClass('support')
          .text(str)
          
        $tag = $(appendTo)
        if $tag.length
          $tag.append($asset)
        else
          $ = cheerio.load($asset.html() + '\n' + $.html())
      
      if finished()
        return next(null, $.html())
