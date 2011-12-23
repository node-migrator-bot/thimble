
###
  Tests for the embed plugin
###

thimble = require '../'

describe 'plugin', ->
  describe '.embed', ->
    
    options = 
      root : __dirname + '/fixtures/'
      empty : true
      
    # Currently does not work at all, options not defined (namespace), support file not checked
    it 'should precompile handlebars', (done) ->
      str = "<script type = 'text/template' src = '/template.hb'>"

      # thim = thimble(options)
      # thim.use thimble.embed
      
      thimble.embed str, options, (err, content) ->
        throw err if err
      
        content.should.include "templates['template']"
        done()
      
    it 'should ignore scripts that arent templates', (done) ->
      str = "<script type = 'text/javascript' src = '/template.hb'>"
    
      thimble.embed str, options, (err, content) ->
        throw err if err

        content.should.include "src = '/template.hb'"
      
        done()
        
    it 'should skip templates that it doesnt understand', (done) ->
      str = '<script type = "text/template" src = "/template.newb">'
      
      thimble.embed str, options, (err, content) ->
        throw err if err

        content.should.include 'src = "/template.newb"'
      
        done()