
###
  Tests for the flatten plugin
###

thimble = require '../'
fixtures = __dirname + '/fixtures'

describe 'plugin', ->
  describe '.flatten', ->
    thim = undefined
    
    options =
      root : fixtures
      source : fixtures + '/index.html'
    
    beforeEach (done) ->
      thim = thimble options
      thim.use thimble.flatten
      done()
       
    it 'should include relative files', (done) ->
      relative = "<h2><include src = 'title.html' /></h2>"
      
      thim.eval relative, options, (err, content) ->
        if err
          return done(err)
        
        content.should.include 'This is a pretty important title'
        
        done()
      
    it 'should include absolute files', (done) ->
      absolute = "<h2><include src = '/title.html' /></h2>"
      
      thim.eval absolute, options, (err, content) ->
        if err
          return done(err)
                  
        content.should.include 'This is a pretty important title'
        
        done()
        
    it 'should work with plugins', (done) ->
      str = "<h2><include src = 'post.jade' /></h2>"
      
      thim.eval str, options, (err, content) ->
        if err
          return done(err)
                  
        content.should.include '<p>this is a post</p>'
        
        done()
      
      
    