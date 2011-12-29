fs      = require "fs"
path    = require "path"

cheerio = require "cheerio"

thimble = require "../thimble"
utils = require "../utils"

# Allows this to be the "main" function that gets called
exports = module.exports = (content, options, next) ->
  directory = null
  if options.source
    directory = path.dirname options.source
  else if options.root
    directory = options.root

  if !directory
    return next null, content
  
  # Flatten the content
  flatten content, directory, options, (err, html) ->
    # Pass the err and modified content down the chain
    next err, html

flatten = exports.flatten = (html, directory, options = {}, callback) ->
  root = options.root || directory
  $ = cheerio.load(html)
  # Fix asset paths
  fixPaths $, directory, options.root

  # Gather all includes
  $include = $('include')

  if $include.length is 0
    return callback null, $.html()
  
  # Add focus attribute here
  
  finished = utils.after $include.length

  $include.each (i, elem) ->
    $this = $(elem)
    src = $this.attr('src')
    if src[0] is "/"
      filePath = root + "/" + src
    else
      filePath = directory + "/" + src

    fs.readFile filePath, 'utf8', (err, content) ->
      return callback err if err
      
      # Try to compile the content
      thimble.compile(filePath) content, options, (err, str) ->
        if err and err isnt 'NOCOMPILER'
          return callback err if err

        # Recursively flatten
        flatten str, path.dirname(filePath), options, (err, flattened) ->
          $this.replaceWith flattened

          if finished()
            return callback null, $.html()

tags = [
  'script'
  'link'
  'img'
]

findRelative = exports.findRelative = (directory, root) ->
  directory = path.resolve directory
  root = path.resolve root
  dir = directory.split "/"
  r = root.split "/"

  for d, i in dir
    if r[i] isnt d
      return dir.slice(i).join('/')

  return ""

fixPaths = exports.fixPaths = ($, directory, root) ->
  # Hard-code for now..
  for tag in tags
    attribute = if tag is "link" then "href" else "src"
    
    $(tag).each ->
      $elem = $(this)
      attr = $elem.attr(attribute)

      if attr and attr[0] isnt "/" and !~attr.indexOf('http')
        relPath = findRelative directory, root
        
        $elem.attr(attribute, relPath + '/' + attr)
        
        
        