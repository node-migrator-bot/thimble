express = require "express" 
thimble = require "thimble"

server = express.createServer()

thimble.boot server,
  build : ""
  root : ""
  publc : ""
  extension : ""

server.configure ->
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use express['static']('./public')
  server.use express.favicon()

server.listen 9999