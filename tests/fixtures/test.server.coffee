express = require "express" 
thimble = require "thimble"

server = module.exports = express.createServer()

server.configure ->
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use express.favicon()
  server.use express.logger('dev')
  
thimble.boot server,
  root : __dirname
  build : __dirname + "/finals"
  public : __dirname + "/public"

# server.register ".html",
#   compile : (str) ->
#     ->
#       str

# server.get "*", (req, res) ->
#   url = req.url.slice 1
#   console.log url
#   res.render(url)

# server.set "views", __dirname + "/initials"


# server.get "/", (req, res) ->
#   res.render 'index.html'

server.get "/:page.html", (req, res) ->
  page = req.params.page
  res.render "initials/#{page}.html"

if !module.parent
  server.listen(9999)
  
  