build = exports.build = (assets, public, main, callback) ->
  bundler = require("../bundler")("build.css", public, main)
  
  bundler.bundle assets, (err) ->
    if !assets.length 
      callback err
      
    for asset in assets
      if asset.href
        asset.parentNode.removeChild(asset) if asset.parentNode
  
    createLinkTag assets[0].ownerDocument
    
    callback err

createLinkTag = (document) ->
  link = document.createElement "link"
  link.href = "build.css"
  link.rel = "stylesheet"

  head = document.getElementsByTagName("head")[0]
  head.appendChild link
 
module.exports = exports