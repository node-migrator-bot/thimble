cheerio = require "../node_modules/cheerio"

flatten = require "../src/flatten"

options = 
  root : __dirname
  
html = '<html><include src = "./files/snippet.html"></html>'

flatten.flatten html, __dirname, options, (err, code) ->
  console.log code