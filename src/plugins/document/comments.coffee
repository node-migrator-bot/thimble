src = "../.."
utils = require "#{src}/utils"
_ = require "underscore"
$ = require "jquery"
fs = require "fs"
jsdom = require("jsdom").jsdom
path = require "path"

assetTypes = require "#{src}/tags/tags"

class CommentParser 
  
  constructor : (@document, @main) ->
  
  parse : (callback, document = @document, directory = @main) ->
    parser = this
    regex = /<!--=\s*(include) ["']?([\w\/.-]+)["']?\s*-->/g
    # console.log document
    # If there are no includes

    matches = []
    while match = regex.exec(document)
      matches.push [match[0], match[1], match[2]]

    numMatches = matches.length
    callback(document) if numMatches is 0
    finished = utils.countdown numMatches

    for match in matches
      do (match) ->
        [original, command, source] = match
        file = directory + "/" + source
      
        fs.readFile file, "utf8", (err, contents) ->
          throw err if err
        
          contents = parser.fixPaths jsdom(contents), path.dirname(source)
        
          output = (fragment) ->
            document = document.replace(original, fragment)
          
            if finished()
              callback(document)
        
          parser.parse output, contents, path.dirname(file)
  
  fixPaths : (document, path) ->

    for type, tag of assetTypes
      attribute = if type is "css" then "href" else "src"

      $(tag, document).each (i, element) ->
        $(element).attr(attribute, path + "/" + element[attribute])
        
    return document.innerHTML

module.exports = CommentParser