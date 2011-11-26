express = require "express"
thimble = require "../src/thimble"

server = express.createServer()

server.configure ->
  server.use express.favicon()
  
thimble.boot server, 
  root : "./client"
  paths :
    support : "./support"

server.get "/", (req, res) ->
  res.render("index/index")
  
  
server.listen 8000
