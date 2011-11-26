fs      = require "fs"
path    = require "path"

cheerio = require "../node_modules/cheerio"

utils = require "./utils"

flatten = exports.flatten = (html, directory, options = {}, callback) ->
  root = options.root || directory
  $ = cheerio.load(html)
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
html = '<html><include src = "../test/files/index.html"></html>'

flatten html, __dirname, options, (err, code) ->
  console.log code