
thimble = require '../'
should = require 'should'

describe 'plugin', ->
  describe '.compile', ->
    thim = undefined
    
    fixtures = __dirname + '/fixtures'
    options = 
      root : fixtures
      plugins : []
    
    beforeEach (done) ->
      thim = thimble(options)
      done()
      
    ###
      Wait till leaky var is fixed
    ###
    # it 'should compile stylus', (done) ->
    #   file = fixtures + '/style.styl'
    #   
    #   options = 
    #     root : fixtures
    # 
    #   thimble.compile(file) null, options, (err, str) ->
    #     throw err if err
    # 
    #     str.should.include 'color: #999;'
    #     
    #     done()
    
    it 'should compile coffeescript', (done) ->
      thim.render 'cool.coffee', {}, (err, str) ->
        throw err if err
        str.should.include 'return console.log("cool");'
        done()
      
      # thimble.compile(file) null, options, (err, str) ->
      #   throw err if err
      #   str.should.include 'console.log("cool")'
        
      
    # it 'should compile handlebars', (done) ->
    #   file = fixtures + '/template.hb'
    #   options.locals = 
    #     planet : 'mars'
    #     
    #   thimble.compile(file) null, options, (err, str) ->
    #     throw err if err
    #     
    #     str.should.include "hello mars!"
    #     
    #     done()
    #     
    # it 'should compile jade', (done) ->
    #   file = fixtures + '/post.jade'
    #   options = {}
    #   
    #   thimble.compile(file) null, options, (err, str) ->
    #     throw err if err
    #     
    #     str.should.include '<p>this is a post</p>'
    #     
    #     done()
        
    it 'should compile markdown', (done) ->
      thim.use thimble.flatten
      str = '<include src = "markdown.md" />'
      thim.eval str, {}, (err, str) ->
        throw err if err

        str.should.include "<h1>Header 1</h1>"
        str.should.include "<strong>hi there</strong>"
        str.should.include "<em>cool</em>"

        done()

      