fs      = require "fs"
path    = require "path"

cheerio = require "../node_modules/cheerio"

utils = require "./utils"

flatten = exports.flatten = (html, directory, options = {}, callback) ->
  root = options.root || directory
  $ = cheerio.load(html)
  
  # Fix asset paths
  fixPaths $, directory

  # Gather all includes
  $include = $('include')
  if $include.length is 0
    return callback null, $.html()
  
  finished = utils.countdown $include.length

  $include.each (i, elem) ->
    $this = $(elem)
    src = $this.attr('src')
    if src[0] is "/"
      filePath = root + "/" + src
    else
      filePath = directory + "/" + src

    fs.readFile filePath, "utf8", (err, content) ->
      throw err if err

      flatten content, path.dirname(filePath), options, (err, flattened) ->
        $this.replaceWith flattened

        if finished()
          return callback null, $.html()

# findRelative = exports.findRelative = (directory, root) ->
#   dir = directory.split "/"
#   r = root.split "/"
# 
#   for d, i in dir
#     if r[i] isnt d
#       return dir.slice(i).join('/')
# 
#   return ""

tags = [
  'script'
  'link'
  'img'
]

fixPaths = exports.fixPaths = ($, directory) ->
  # Hard-code for now..
  for tag in tags
    attribute = if tag is "link" then "href" else "src"
    
    $(tag).each ->
      $elem = $(this)
      attr = $elem.attr(attribute)

      if attr and attr[0] isnt "/"
        $elem.attr(attribute, directory + '/' + attr)
      console.log this
      
module.exports = exports