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
  
  pull : (element = @document) ->
    output = []
    self = this

    current = element
    # while current
    children = current.childNodes
    for child in children
      # console.log child.nodeName if child.nodeType is 1
      
      if child.nodeType is 8
        output.push child
      else
        output = output.concat self.pull child
    
    return output
  
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

  _parse : (document = @document, directory = @main, callback) ->
    parser = this
    comments = @pull(document)
    regex = /^=\s*(include) ["']?([\w\/.-]+)["']?/
    commands = []
    for comment in comments
      text = comment.nodeValue

      if regex.test text
        commands.push comment
    
    numCommands = commands.length
    callback(document) if numCommands is 0
    finished = utils.countdown numCommands
    
    $(commands).each (index, comment) ->

      [match, command, source] = comment.nodeValue.match regex

      file = directory + "/" + source

      fs.readFile file, "utf8", (err, contents) ->
        throw err if err
        
        documentFragment = jsdom(contents)
        parser.fixPaths documentFragment, path.dirname(source)

        output = (fragment) ->
          # Work-around for WRONG DOCUMENT error
          elems = $(fragment.innerHTML, document).get()
          parent = comment.parentNode
          
          # Need to insert using vanilla JS in order not to invoke 
          #domManip, which removes <script> tags
          for elem in elems
            parent.insertBefore elem, comment
          
          $(comment).remove()
          
          if finished()
            callback(document)

        parser.parse documentFragment, path.dirname(file), output
  
  fixPaths : (document, path) ->

    for type, tag of assetTypes
      attribute = if type is "css" then "href" else "src"

      $(tag, document).each (i, element) ->
        $(element).attr(attribute, path + "/" + element[attribute])
        
    return document.innerHTML

isString = (obj) ->
  !!(obj is '' || (obj && obj.charCodeAt && obj.substr));

createScript = (src) ->
  return $("<script>").attr('type', 'text/javascript').attr('src', src)

module.exports = CommentParser