build = exports.build = (assets, public, main, callback) ->
  bundler = require("../bundler")("build.js", public, main)
  
  bundler.bundle assets, (err) ->
    if assets[0]
      moveJS assets[0].ownerDocument
    callback err
  

moveJS = (document) ->
  scripts = document.getElementsByTagName("script")
  
  html = document.children[0]
  # Should only be one by now but just in case    
  for script in scripts
    html.appendChild(script)

module.exports = exports
  