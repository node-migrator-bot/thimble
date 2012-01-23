should = require "should"

thimble = require '../'
fixtures = __dirname + '/fixtures'

    
options =
  root : fixtures


describe 'server', ->
  options =
    root : fixtures
    source : fixtures + '/index.html'
  
  beforeEach (done) ->
    thimble = thimble.create(options)
    thimble.use thimble.flatten()
    done()

  describe '.start', ->
    
