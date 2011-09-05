express = require "express"
thimble = require "thimble"
tobi = require "tobi"
assert = require "assert"
should = require "should"

# Create the server
server = express.createServer()

# Initialize thimble
thimble.boot server,
  root : "../fixtures"
  public : "../fixtures/public"
  build : "../fixtures/build"

browser = tobi.createBrowser server

browser.get "/assets/stylish.styl", (res, $) ->
  res.should.have.status 200
  res.should.have.header('Content-Length')
  res.should.have.header('Content-Type', 'text/css; charset=UTF-8')
  
browser.get "/assets/rofl.css", (res, $) ->
  res.should.have.status 200
  res.should.have.header('Content-Length')
  res.should.have.header('Content-Type', 'text/css; charset=UTF-8')
  
browser.get "/assets/lessy.less", (res, $) ->
  res.should.have.status 200
  res.should.have.header('Content-Length')
  res.should.have.header('Content-Type', 'text/css; charset=UTF-8')

browser.get "/assets/hello.coffee", (res, $) ->
  res.should.have.status 200
  res.should.have.header('Content-Length')
  res.should.have.header('Content-Type', 'application/javascript')

browser.get "/assets/alert.js", (res, $) ->
  res.should.have.status 200
  res.should.have.header('Content-Length')
  res.should.have.header('Content-Type', 'application/javascript')