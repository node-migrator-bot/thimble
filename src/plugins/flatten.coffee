fs      = require "fs"
{dirname, extname}    = require "path"

cheerio = require "cheerio"

thimble = require "../thimble"
{after, relative, step} = require "../utils"

# Allows this to be the "main" function that gets called
exports = module.exports = (content, options, next) ->
  directory = null
  if options.source
    directory = dirname options.source
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
  
  finished = after $include.length

  $include.each (i, elem) ->
    $this = $(elem)
    src = $this.attr('src')
    if src[0] is "/"
      filePath = root + "/" + src
    else
      filePath = directory + "/" + src

    read = (next) ->
      fs.readFile(filePath, 'utf8', next)

    compile = (err, content, next) ->
      return callback(err) if err
      
      if (extname(filePath) is extname(options.source))
        return next(err, content)
      else
        return thimble.compile(filePath) content, options, next
    
    flattener = (err, str, done) ->
      return callback(err) if err
      flatten str, dirname(filePath), options, done
      
    done = (err, flattened) ->
      return callback(err) if err
      $this.replaceWith flattened
      
      if finished()
        return callback err, $.html()
    
    step(read, compile, flattener, done)

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

      if attr and attr[0] isnt "/" and !~attr.indexOf('http')
        relPath = relative directory, root
        
        $elem.attr(attribute, relPath + '/' + attr)
        
        
        