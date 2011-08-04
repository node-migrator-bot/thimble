express = require "express" 
path = require "path"
app = express.createServer()
lib = __dirname
CommentParser = require "./parsers/comments"
fs = require "fs"


serve = exports.serve = (appDir, port) ->

  app.configure ->
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.favicon()
    app.use require("./middleware")(appDir)
    app.use express['static'](appDir)

  app.register '.html',
    compile : (str) ->
      ->
        str
  
  app.get "/:module?/", (req, res) ->
    module = req.params["module"] or ""
    index = if module then "#{module}.html" else "app.html"
    baseDir = appDir + module + "/"
    
    file = baseDir + index

    fs.readFile file, "utf8", (err, html) ->
      parser = new CommentParser html, baseDir
      parser.parse null, null, (document) ->
        res.send document.innerHTML
  
  console.log "Starting thimble server on port #{port}"
  app.listen port
  

module.exports = exports