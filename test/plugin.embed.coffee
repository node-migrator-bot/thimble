###
  Tests for the embed plugin
###

thimble = require '../'

describe 'plugin', ->
  describe '.embed', ->
  
    options = 
      root : __dirname + '/fixtures/'
      support : {}
  
    it 'should precompile handlebars', (done) ->
      str = "<script type = 'text/template' src = '/template.hb'>"
    
      thimble.embed str, options, (err, content) ->
        throw err if err

        content.should.include.string "templates['template']"
      
        done()
      
    it 'should ignore scripts that arent templates', (done) ->
      str = "<script type = 'text/javascript' src = '/template.hb'>"
    
      thimble.embed str, options, (err, content) ->
        throw err if err

        content.should.include.string "src = '/template.hb'"
      
        done()
        
    it 'should skip templates that it doesnt understand', (done) ->
      str = '<script type = "text/template" src = "/template.newb">'
      
      thimble.embed str, options, (err, content) ->
        throw err if err

        content.should.include.string 'src = "/template.newb"'
      
        done()