# Just a list of the various tags that request assets from the server

types = exports.types =
  js : "script"
  css : "link"
  images : "img"
  embeds : "embed"
  iframes : "iframe"
  videos : "video"
  audio : "audio"
  
patches = exports.patches =
  "embed" : 
    attributes : ["src", "type"]
    
module.exports = exports