express = require "express" 
path = require "path"
app = express.createServer()
lib = __dirname

serve = exports.serve = (appDir, port) ->
  # middle = require("#{__dirname}/middleware.coffee")

  app.configure ->
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.favicon()
    app.use require(lib + "/middleware.coffee")(appDir)
    app.use express['static'](appDir)

  app.register '.html',
    compile : (str) ->
      ->
        str
  
  app.get "/:module?/", (req, res) ->
    module = req.params["module"] or ""
    index = if module then "#{module}.html" else "app.html"
    baseDir = appDir + module + "/"
  
    res.render baseDir + index, layout : false
  
  app.listen port
  

module.exports = exports