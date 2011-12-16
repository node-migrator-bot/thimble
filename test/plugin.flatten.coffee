###
  Tests for the flatten plugin
###

thimble = require '../'
fixtures = __dirname + '/fixtures'

describe 'plugin', ->
  describe '.flatten', ->
    
    options =
      root : fixtures
      source : fixtures + '/index.html'
        
    it 'should include relative files', (done) ->
      relative = "<h2><include src = 'title.html' /></h2>"
      
      thimble.flatten relative, options, (err, content) ->
        throw err if err
        
        content.should.include.string 'This is a pretty important title'
        
        done()
      
    it 'should include absolute files', (done) ->
      absolute = "<h2><include src = '/title.html' /></h2>"
      
      thimble.flatten absolute, options, (err, content) ->
        throw err if err
        
        content.should.include.string 'This is a pretty important title'
        
        done()
        
    it 'should work with plugins', (done) ->
      str = "<h2><include src = 'post.jade' /></h2>"
      
      thimble.flatten str, options, (err, content) ->
        throw err if err
        
        content.should.include.string '<p>this is a post</p>'
        
        done()
      
      
    