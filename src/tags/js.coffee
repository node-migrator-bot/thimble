build = exports.build = (assets, public, main, callback) ->
  bundler = require("../bundler")("build.js", public, main)

  bundler.bundle assets, (err) ->
    if !assets.length 
      callback err
      
    for asset in assets
      if asset.src
        asset.parentNode.removeChild(asset) if asset.parentNode
  
    createScriptTag assets[0].ownerDocument
    
    callback err
  

createScriptTag = (document) ->
  script = document.createElement "script"
  script.src = "build.js"
  script.type = "text/javascript"
  script.defer = "defer"

  html = document.children[0]
  html.appendChild(script)

module.exports = exports
  