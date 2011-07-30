lib = "#{__dirname}/.."
utils = require lib + "/utils.coffee"
_ = require "underscore"
$ = require "jquery"
fs = require "fs"
jsdom = require("jsdom").jsdom
path = require "path"

class CommentParser 
  
  constructor : (@document, @main) ->
    if isString document
      @document = jsdom(document)
  
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
         
  parse : (document = @document, directory = @main, callback) ->
    parser = this
    comments = @pull(document)
    regex = /(include) ["']([\w\/.-]+)["']/
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
        # parser.fixPaths documentFragment, path.dirname(embed.src)

        output = (fragment) ->
          $(comment).replaceWith(fragment.innerHTML)
          if finished()
            callback(document)

        console.log "--"
        parser.parse documentFragment, path.dirname(file), output
      
    # for comment in comments
    #    text = comment.nodeValue
    #    [match, command, arg] = text.match /(include) ["']?([\w\/.-]+)["']?/
    #    
    #    if arg
    #      sources[arg] = comment
    #  
    # 
    #  
    # 
     # sources.each ->
     #   embed = this
     #   file = directory + "/" + embed.src
     #     
     #   fs.readFile file, "utf8", (err, contents) ->
     #     throw err if err
     #     
     #     documentFragment = jsdom(contents)
     #     builder.fixPaths documentFragment, path.dirname(embed.src)
     #     
     #     output = (fragment) ->
     #       $(embed).replaceWith(fragment.innerHTML)
     #       if finished()
     #         callback(document)
     #         
     #     builder.flatten documentFragment, path.dirname(file), output
    #  
    #  for source, element of sources
    #    fs.readFile @main + "/" + 
    #      
    #      
    #  
  
    # $(element).each (index, node) ->
    #      children = node.childNodes
    #      for child in children
    #        if child.nodeType is 8
    #          output.push child
    #        else
    #          output = output.concat self.pull child
    #        
    #    return output

isString = (obj) ->
  !!(obj is '' || (obj && obj.charCodeAt && obj.substr));

module.exports = (html, main) ->
  # console.log html  
  return new CommentParser html, main