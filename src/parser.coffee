fs = require "fs"
path = require "path"
jsdom = require("jsdom").jsdom
emitter = new (require("events").EventEmitter)()

_ = require "underscore"
$ = require "jquery"
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
    flatten done, code, directory, options

  done = (err, contents) ->
    contents = utils.hideTemplateTags contents
    contents = fixPaths jsdom(contents), relativePath
    contents = utils.unhideTemplateTags contents
    callback err, contents

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
  parser = this
  
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

      fs.readFile app, "utf8", (err, contents) ->
        throw err if err
        contents = utils.hideTemplateTags contents
        contents = fixPaths jsdom(contents), path.dirname(source)
        contents = utils.unhideTemplateTags contents

        output = (err, fragment) ->
          throw err if err
          html = html.replace(original, fragment)

          if finished()
            callback(null, html)

        flatten output, contents, path.dirname(app), options

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

fixPaths = (document, p, root = false) ->

  for type, tag of assetTypes
    attribute = if type is "css" then "href" else "src"
    tag = [tag] if not _.isArray(tag)
    tag = tag.join(",")
    $(tag, document).each (i, element) ->
      attr = $(element).attr(attribute)
        
      if attr and attr[0] isnt "/"
        $(element).attr(attribute, p + "/" + element[attribute])
        

  return document.innerHTML
  

module.exports = exports