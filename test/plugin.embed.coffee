
###
  Tests for the embed plugin
###

thimble = require '../'

describe 'plugin', ->
  describe '.embed', ->
    thim = undefined
    
    options = 
      root : __dirname + '/fixtures/'
      plugins : []
      
    beforeEach (done) ->
      thim = thimble(options)
      # console.log thim.settings('support files')
      thim.use thimble.embed
      thim.use thimble.support
      done()
      
    # Currently does not work at all, options not defined (namespace), support file not checked
    it 'should precompile handlebars', (done) ->
      str = "<script type = 'text/template' src = '/template.hb'>"

      thim.eval str, {}, (err, content) ->
        # Make sure the support file was included
        content.should.include 'Handlebars.registerHelper'
        # Make sure the template was added
        content.should.include "window.JST['template']"

        done()
      
      
    it 'should ignore scripts that arent templates', (done) ->
      str = "<script type = 'text/javascript' src = '/template.hb'>"

      thim.eval str, {}, (err, content) ->
        content.should.include "src = '/template.hb'"
        content.should.not.include "window.JST['template']"
        content.should.not.include 'Handlebars.registerHelper'
        
        done()
        
    it 'should skip templates that it doesnt understand', (done) ->
      str = '<script type = "text/template" src = "/template.newb">'
      
      thim.eval str, {}, (err, content) ->

        content.should.include 'src = "/template.newb"'
        content.should.not.include "window.JST['template']"
        content.should.not.include 'Handlebars.registerHelper'
        
        done()