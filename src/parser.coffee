fs = require "fs"
path = require "path"
cheerio = require "cheerio"
emitter = new (require("events").EventEmitter)()

_ = require "underscore"
utils = require "./utils"
assetTypes = require("./tags/tags").types

parse = exports.parse = (app, options, callback) ->
  directory = path.dirname app
  relativePath = findRelative directory, options.root

  emitter.once "read", (code) ->
    if options.layout
      wrap code, options
    else emitter.emit "wrapped", code
  
  emitter.once "wrapped", (code) ->
    # Root layer needs paths fixed if root differs from bottom js layer
    code = utils.hideTemplateTags code
    fixPaths code, relativePath, (err, html) ->
      html = utils.unhideTemplateTags html
      flatten done, html, directory, options

  done = (err, contents) ->
    throw err if err
    contents = utils.hideTemplateTags contents
    contents = fixPaths contents, relativePath, (err, html) ->
      html = utils.unhideTemplateTags html
      callback err, html

  read app

###
  PRIVATE
###

read = (app) ->
  fs.readFile app, "utf8", (err, code) =>
    throw err if err
    emitter.emit "read", code

wrap = (innerHTML, options) ->
  outerFile = options.layout
  
  fs.readFile outerFile, "utf8", (err, code) ->
    throw err if err

    open = options.tags?.open or "<!--="
    close = options.tags?.close or "-->"

    regex = ///
      #{open}
      \s*
      yield
      \s*
      #{close}
    ///
    
    code = code.replace regex, innerHTML
    emitter.emit "wrapped", code

flatten = (callback, html, directory, options) ->
  
  root = options.root  
  open = options.tags?.open or "<!--="
  close = options.tags?.close or "-->"

  regex = ///
    #{open}
    \s*
    (include)
    \s
    ["']?([\w\/.-]+)["']?
    \s*
    #{close}
  ///g
  
  matches = []
  while match = regex.exec(html)

    matches.push [match[0], match[1], match[2]]

  numMatches = matches.length
  callback(null, html) if numMatches is 0
  finished = utils.countdown numMatches

  for match in matches
    do (match) ->
      [original, command, source] = match
      if source[0] is "/"
        app = root + source
      else
        app = directory + "/" + source
        
      relativePath = findRelative(app, options.root)
      
      fs.readFile app, "utf8", (err, contents) ->
        throw err if err
        
        output = (err, fragment) ->
          throw err if err
          html = html.replace(original, fragment)

          if finished()
            callback(null, html)
        
        contents = utils.hideTemplateTags contents

        contents = fixPaths contents, path.dirname(source), (html) ->
          html = utils.unhideTemplateTags html
          flatten output, html, path.dirname(app), options

###
  UTILITIES
###

findRelative = (directory, root) ->
  dir = directory.split "/"
  r = root.split "/"

  for d, i in dir
    if r[i] isnt d
      return dir.slice(i).join('/')
 
  return ""

# Overwrite assetTypes for now.
# tags = _(_(assetTypes).values()).flatten().join(", ")
tags = [
  'script'
  'link'
  'img'
]

fixPaths = (content, p, callback) ->
  cheerio content, (err, $) ->
    # Hard-code for now..
    for tag in tags
      attribute = if tag is "link" then "href" else "src"
      
      $(tag).each ($elem) ->
        attr = $elem.attr(attribute)
        
        if attr and attr[0] isnt "/"
          $elem.attr(attribute, p + '/' + attr)

      
    
    callback err, $.html()
      # $(tag, document).each (i, element) ->
      #   attr = $(element).attr(attribute)
      # 
      #   if attr and attr[0] isnt "/"
      #     $(element).attr(attribute, p + "/" + element[attribute])        

  # return document.innerHTML
  

module.exports = exports