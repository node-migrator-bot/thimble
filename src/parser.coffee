fs = require "fs"
path = require "path"
jsdom = require("jsdom").jsdom
emitter = new (require("events").EventEmitter)()

_ = require "underscore"
$ = require "jquery"
{countdown, hideTemplateTags, unhideTemplateTags} = require "./utils"
assetTypes = require("./tags/tags").types

parse = exports.parse = (file, options, callback) ->
  directory = path.dirname file
  relativePath = findRelative directory, options.root
  
  # If there aren't any options then it's the callback
  if _.isFunction options
    callback = options
    
  emitter.once "read", (code) ->
    if options.layout
      wrap(code, options.layout)
    else emitter.emit "wrapped", code
  
  emitter.once "wrapped", (code) ->
    flatten done, code, directory

  done = (err, contents) ->
      contents = hideTemplateTags contents
      contents = fixPaths jsdom(contents), relativePath
      contents = unhideTemplateTags contents
      callback err, contents

  read file

###
  PRIVATE
###

read = (file) ->
  fs.readFile file, "utf8", (err, code) =>
    throw err if err
    emitter.emit "read", code

wrap = (innerHTML, outerFile) ->
  fs.readFile outerFile, "utf8", (err, code) ->
    throw err if err

    code = code.replace /<!--=\s*yield\s*-->/, innerHTML
    emitter.emit "wrapped", code

flatten = (callback, html, directory) ->
  parser = this
  regex = /<!--=\s*(include) ["']?([\w\/.-]+)["']?\s*-->/g
  # console.log html
  # If there are no includes

  matches = []
  while match = regex.exec(html)
    matches.push [match[0], match[1], match[2]]

  numMatches = matches.length
  callback(null, html) if numMatches is 0
  finished = countdown numMatches

  for match in matches
    do (match) ->
      [original, command, source] = match
      file = directory + "/" + source

      fs.readFile file, "utf8", (err, contents) ->
        throw err if err
        contents = hideTemplateTags contents
        contents = fixPaths jsdom(contents), path.dirname(source)
        contents = unhideTemplateTags contents

        output = (err, fragment) ->
          throw err if err
          html = html.replace(original, fragment)

          if finished()
            callback(null, html)

        flatten output, contents, path.dirname(file)

###
  UTILITIES
###

findRelative = (directory, root) ->
  dir = directory.split "/"
  r = root.split "/"
   
  for d, i in dir
    if r[i] isnt d
      return "./" + dir.slice(i).join('/')
 
  return "."

fixPaths = (document, path) ->

  for type, tag of assetTypes
    attribute = if type is "css" then "href" else "src"

    $(tag, document).each (i, element) ->
      attr = $(element).attr(attribute)
      if attr and attr[0] isnt "/"
        $(element).attr(attribute, path + "/" + element[attribute])

  return document.innerHTML

module.exports = exports