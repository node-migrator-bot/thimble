lib = "#{__dirname}/.."
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()

build = exports.build = (assets, public, main, output) ->

  # Pull out the sources and make them absolute
  sources = (main + "/" + elem["src"] for elem in assets) 
  
  # Use the first one for now.
  appPath = sources[0]
  
  builder = require(lib + "/builder.coffee")(appPath, public)

  builder.build (err, html) ->
    throw err if err
    modify asset, html
    
    output null
  
modify = exports.modify = (asset, html) ->
  # Use the first one for now
  asset = assets[0]
  $ = require "jquery"
  
  $(asset).replaceWith(html)

  
  # frag = document.createDocumentFragment(fragment.innerHTML)

  # console.log asset

  # console.log fragment.createDocumentFragment()

  # console.log fragment
  
  
  # asset.appendChild(frag)
  
  # console.log frag.childNodes
  
  # if next
  #   for node in frag.childNodes
  #     next.parentNode.insertBefore(node, next)
  # else
  #   parent.appendChild frag.childNodes
  # 
  # builder = require lib + "/builder.coffee"
  

# read = exports.read = (files, emitter)


module.exports = exports
