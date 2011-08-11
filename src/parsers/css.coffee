build = exports.build = (assets, public, main, callback) ->
  bundler = require("./bundler")("build.css", public, main)
  
  # Capture output just to verify that our css is at the bottom of <head> and not elsewhere in the document
  output = (err) ->
    if assets[0]
      moveCSS(assets[0].ownerDocument)
    callback err
  
  bundler.bundle assets, output

moveCSS = (document) ->
  links = document.getElementsByTagName("link")
  head = document.getElementsByTagName("head")[0]
  
  # Should only be one by now but just in case    
  for link in links
    head.appendChild(link)
  
 
module.exports = exports