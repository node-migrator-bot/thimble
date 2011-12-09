express = require "express"
thimble = require "../src/thimble"

server = express.createServer()

server.configure ->
  server.use express.favicon()

t = thimble.create
  root: './client'
  paths :
    support : './support'

t.configure ->
  t.use thimble.layout
  # t.use thimble.focus()
  # t.use thimble.flatten()
  
t.start server

#   
# 
# thimble.configure
#   root : "./client"
#   paths :
#     support : "./support"
#     
# thimble.start(server)

server.get "/", (req, res) ->
  res.render("index/index")
  
  
server.listen 8000
