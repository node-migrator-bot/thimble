fs = require 'fs'
path = require 'path'

cheerio = require '../node_modules/cheerio'

# flattener = require './flatten'
language = require './language'
utils = require './utils'

emitter = new (require('events').EventEmitter)()

render = exports.render = (app, options, callback) ->
  
  emitter.once "read", (contents) ->
    # Flatten the file
    flattener.flatten contents, path.dirname(app), options, (err, flattened) ->
      throw err if err
      emitter.emit "flattened", flattened
  
  emitter.once "flattened", (content) ->
    $ = cheerio.load content
    
    emitter.once "inline:finished", ->
      callback null, $.html()
    
    $scripts = $('script[type=text/template]')
    if $scripts.length
      inlineTemplates $scripts, options, $
    else
      emitter.emit "inline:finished"
      

  # Read the file
  fs.readFile app, 'utf8', (err, content) ->
    throw err if err
    
    emitter.emit "read", content


inlineTemplates = ($scripts, options, $) ->
  finished = utils.countdown $scripts.length
  
  $scripts.each ->
    $script = $(this)
    src = $script.attr('src')
    
    if src
      template = language(src)

      fs.readFile options.root + '/' + src, 'utf8', (err, contents) ->
        throw err if err
        
        if id = $script.attr('id')
          name = id
        else
          parts = src.split('.')
          parts.pop()
          name = parts.join('.')
        
        options.template = name

        template.compile contents, src, options, (err, js) ->
          throw err if err

          # Add the compiled script
          $script.text(js)
          
          # Remove the src and change type to text/javascript
          $script.removeAttr('src').attr('type', 'text/javascript')
          
          if finished()
            emitter.emit "inline:finished"
          
    else
      console.log "Internal templates not yet supported"
      
      if finished()
        emitter.emit "inline:finished"
      
      