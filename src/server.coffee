###
  server.coffee --- Matt Mueller
  
  The purpose of this provide a way of diving into a specific UI asset.
  Rather than being required to work with the application in whole, this 
  lets you work on just the colorpicker, or just the calendar, allowing you
  to fine-tune your ui to perfection
  
  You simply run "thimble server UI_DIR" in the terminal to start fine tuning 
  your application.
  
###

express       = require "express" 
path          = require "path"
app           = express.createServer()
lib           = __dirname
CommentParser = require "./parsers/comments"
fs            = require "fs"

serve = exports.serve = (appDir, port) ->

  app.configure 'development', ->
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.favicon()
    app.use require("./index").middleware(appDir)
    app.use express['static'](appDir)
    app.use express.errorHandler dumpExceptions: true, showStack: true
    
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
        console.log document
        res.send document
  
  console.log "Starting thimble server on port #{port}"
  app.listen port
  

module.exports = exports