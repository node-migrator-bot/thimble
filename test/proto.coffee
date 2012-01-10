should = require "should"

thimble = require '../'
fixtures = __dirname + '/fixtures'



describe 'proto', ->
  describe '.render', ->
    thim = undefined
    
    options =
      root : fixtures
      
    beforeEach (done) ->
      thim = thimble.create(options)
      done()
    
    it 'should render basic html correctly', (done) ->

      thim.render 'index.html', {}, (err, content) ->
        throw err if err
        
        content.should.include "cool story, man."
        
        done()
        
    it 'should render with a layout', (done) ->
      
      thim.render 'title.html', { layout : 'layout.html' }, (err, content) ->
        throw err if err

        content.should.include '<html>This is a pretty important title</html>'
        
        done()
        
    it 'should take allow a function as the 2nd parameter', (done) ->
      
      thim.render 'index.html', (err, content) ->
        throw err if err
        
        content.should.include "cool story, man."
        
        done()
  
  describe '.use', ->
    thim = undefined
    
    options =
      root : fixtures
      
    beforeEach (done) ->
      thim = thimble.create(options)
      done()
    
    it 'should add to the stack', ->
      before = thim.stack.length
      thim.use thimble.support
      after = thim.stack.length
      
      after.should.equal before + 1
      
   
  describe '.configure', ->
    thim = undefined
    
    options =
      root : fixtures
    
    beforeEach (done) ->
      thim = thimble.create(options)
      done()
    
    # stupid minify
    minify = (content, options, next) ->
      next null, content.replace /\s+/g, ''
      
    it 'doesnt minify in development', (done) ->
      
      thim.configure 'production', ->
        thim.use minify
      
      thim.render 'index.html', (err, content) ->
        
        content.should.include "cool story, man."
        
        done()
        
    it 'minifies in production', (done) ->
      thim.settings.env = 'production'
      
      thim.configure 'production', ->
        thim.use minify
      
      thim.render 'index.html', (err, content) ->
        content.should.include "coolstory,man."
        
        done()
        
  describe '.set', ->
    thim = undefined
    
    options =
      root : fixtures
      
    beforeEach (done) ->
      thim = thimble.create(options)
      done()
    
    it 'should set the setting if second arg is present', ->
      thim.set('env', 'staging')
      thim.settings.env.should.equal 'staging'

  describe '.get', ->
    thim = undefined

    options =
      root : fixtures
      
    beforeEach (done) ->
      thim = thimble.create(options)
      done()
    
    it 'should get setting if second arg undefined', ->
      thim.get('env').should.equal 'development'

    it 'should return undefined if we get a non-existent setting', ->
      test = thim.get('lolcats') is undefined
      test.should.be.true

