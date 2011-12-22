express = require "express"
thimble = require "../src/thimble"

server = express.createServer()

server.configure ->
  server.use express.favicon()
  server.use express.static('./public')

thim = thimble.create
  root: './client'
  paths :
    support : './support'

# t.configure ->
  # t.use thimble.layout
  # t.use thimble.focus()
  # t.use thimble.flatten()
  
thim.start server


#   
# 
# thimble.configure
#   root : "./client"
#   paths :
#     support : "./support"
#     
# thimble.start(server)

server.get "/", (req, res) ->
  res.render "index/index",
    planet : 'mars'
    name : 'matt'
  
  
server.listen 8000
console.log "Server listening on port 8000"

# t.render './files/test.jade', {planet : 'mars', name : 'matt', layout : 'layout2.html'}, (err, content) ->
#   console.log err if err
#   console.log content