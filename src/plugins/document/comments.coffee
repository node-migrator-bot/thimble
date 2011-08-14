src = "../.."
{countdown, hideTemplateTags, unhideTemplateTags} = require "#{src}/utils"
_ = require "underscore"
$ = require "jquery"
fs = require "fs"
jsdom = require("jsdom").jsdom
path = require "path"
emitter = new (require("events").EventEmitter)()

assetTypes = require("#{src}/tags/tags").types

###
  PUBLIC
###

render = exports.render = (html, file, options = {}, output) ->
  directory = path.dirname file
   
  # If there aren't any options then it's the callback
  if _.isFunction options
    output = options
 
  emitter.once "initialized", (html) ->
    parse output, html, directory

  initialize html, file, options, emitter

###
  PRIVATE
###

initialize = (html, file, options, emitter) ->
  {outer} = options

  if outer
    emitter.once "wrapped", (html) ->
      emitter.emit "initialized", html

    wrap(html, outer, emitter)

  else
    emitter.emit "initialized", html  
  
parse = (callback, html, directory) ->
  parser = this
  regex = /<!--=\s*(include) ["']?([\w\/.-]+)["']?\s*-->/g
  # console.log html
  # If there are no includes

  matches = []
  while match = regex.exec(html)
    matches.push [match[0], match[1], match[2]]

  numMatches = matches.length
  callback(html) if numMatches is 0
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
      
        output = (fragment) ->
          html = html.replace(original, fragment)
        
          if finished()
            callback(html)
      
        parse output, contents, path.dirname(file)

###
  OPTIONS
###

wrap = (innerHTML, outer, emitter) ->
  fs.readFile outer, "utf8", (err, html) ->
    throw err if err

    html = html.replace /<!--=\s*yield\s*-->/, innerHTML
    emitter.emit "wrapped", html

###
  UTILITIES
###

fixPaths = (document, path) ->

  for type, tag of assetTypes
    attribute = if type is "css" then "href" else "src"

    $(tag, document).each (i, element) ->
      $(element).attr(attribute, path + "/" + element[attribute])
      
  return document.innerHTML

module.exports = exports