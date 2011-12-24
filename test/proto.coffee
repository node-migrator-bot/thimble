
###
  Needs updating!
###

thimble = require '../'
fixtures = __dirname + '/fixtures'

# Fixtures
index = fixtures + '/index.html'
layout = fixtures + '/layout.html'
title = fixtures + '/title.html'
template = fixtures + '/template.hb'

describe 'proto', ->
  describe '.render', ->
    thim = thimble()
    
    it 'should render basic html correctly', (done) ->

      thim.render index, {}, (err, content) ->
        throw err if err
        
        content.should.include "cool story, man."
        
        done()
        
    it 'should render with a layout', (done) ->
      
      thim.render title, { layout : layout }, (err, content) ->
        throw err if err
        
        content.should.include '<html>This is a pretty important title</html>'
        
        done()
        
    it 'should take allow a function as the 2nd parameter', (done) ->
      
      thim.render index, (err, content) ->
        throw err if err
        
        content.should.include "cool story, man."
        
        done()
  
    it 'should render something with local variables', (done) ->
      
      thim.render template, {planet : 'venus'}, (err, content) ->
        throw err if err
        
        content.should.equal '<h2>hello venus!</h2>'
        
        done()
  
  describe '.use', ->
    thim = thimble()
    
    it 'should add to the stack', ->
      before = thim.stack.length
      thim.use thimble.support
      after = thim.stack.length
      
      after.should.equal before + 1
      
   
  describe '.configure', ->
    thim = thimble()
    
    # stupid minify
    minify = (content, options, next) ->
      next null, content.replace /\s+/g, ''
      
    it 'doesnt minify in development', (done) ->
      
      thim.configure 'production', ->
        thim.use minify
      
      thim.render index, (err, content) ->
        
        content.should.include "cool story, man."
        
        done()
        
    it 'minifies in production', (done) ->
      thim.settings.env = 'production'
      
      thim.configure 'production', ->
        thim.use minify
      
      thim.render index, (err, content) ->
        content.should.include "coolstory,man."
        
        done()
        
  describe '.set', ->
    thim = thimble()

    it 'should get setting if second arg undefined', ->
      thim.set('env').should.equal 'development'
    
    it 'should set the setting if second arg is present', ->
      thim.set('env', 'staging')
      thim.settings.env.should.equal 'staging'
      
    it 'should return undefined if we get a non-existent setting', ->
      test = thim.set('lolcats') is undefined
      test.should.be.true
      
    
  describe '.support', ->
    
    it 'should set the support files of the application', ->
      thim = thimble()
      thim.support "handlebars.js"
      
      files = thim.settings('support files')
      files[0].file.should.equal 'handlebars.js'
    
    