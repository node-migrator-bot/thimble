cheerio = require "../node_modules/cheerio"
fs = require 'fs'
flatten = require "../src/flatten"

options = 
  root : __dirname
  
html = '<html><include src = "./files/snippet.html"></html>'

flatten.flatten html, __dirname, options, (err, code) ->
  throw err if err 
    
  fs.writeFileSync "out.html", code, "utf8"
  