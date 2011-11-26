fs      = require "fs"
path    = require "path"

$ = require "../node_modules/cheerio"

utils   = require "./utils"

flatten = exports.flatten = (html, directory, options, callback) ->
  root = options.root
  $includes = $('include', html)
  numIncludes = $includes.length

  if numIncludes is 0
    return callback null, html
    
  finished = utils.countdown numIncludes

  $includes.each ->
    $this = $(this)
    src = $this.attr('src')

    if !src and finished()
      return callback null, html

    if src[0] is "/"
      filePath = root + "/" + src
    else
      filePath = directory + "/" + src

    utils.readFile filePath, (err, code) ->
      throw err if err

      output = (err, fragment) ->
        $this.before(fragment)
        $this.remove()
        
        if finished()
          return callback null, code
          
      flatten code, path.dirname(filePath), options, output

findRelative = exports.findRelative = (directory, root) ->
  dir = directory.split "/"
  r = root.split "/"

  for d, i in dir
    if r[i] isnt d
      return dir.slice(i).join('/')

  return ""

fixPaths = exports.fixPaths = ($) ->
  

module.exports = exports
options = {}
html = '<html><include src = "../test/files/snippet.html"></html>'

flatten html, __dirname, options, (err, code) ->
  console.log code