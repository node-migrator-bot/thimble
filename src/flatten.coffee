fs      = require "fs"
path    = require "path"

cheerio = require "../node_modules/cheerio"

utils = require "./utils"

flatten = exports.flatten = (html, directory, options = {}, callback) ->
  root = options.root || directory
  $ = cheerio.load(html)
  
  # Fix asset paths
  fixPaths $, directory, options.root

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

tags = [
  'script'
  'link'
  'img'
]

fixPaths = exports.fixPaths = ($, directory, root) ->
  # Hard-code for now..
  for tag in tags
    attribute = if tag is "link" then "href" else "src"
    
    $(tag).each ->
      $elem = $(this)
      attr = $elem.attr(attribute)


      if attr and attr[0] isnt "/"
        relPath = utils.findRelative directory, root
        $elem.attr(attribute, relPath + '/' + attr)
      
module.exports = exports