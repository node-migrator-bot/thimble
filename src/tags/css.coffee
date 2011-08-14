build = exports.build = (assets, public, main, callback) ->
  bundler = require("../bundler")("build.css", public, main)
  
  bundler.bundle assets, (err) ->
    if !assets.length 
      callback err
      
    for asset in assets
      if asset.href
        asset.parentNode.removeChild(asset) if asset.parentNode
  
    moveCSS assets[0].ownerDocument
    callback err

moveCSS = (document) ->
  links = document.getElementsByTagName("link")
  head = document.getElementsByTagName("head")[0]
  
  # Should only be one by now but just in case    
  for link in links
    head.appendChild(link)
  
 
module.exports = exports