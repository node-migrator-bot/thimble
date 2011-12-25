
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

      # Add the compile middleware
      # thim.use thimble.compile
      
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
      file = fixtures + '/cool.coffee'

      thim.render 'cool.coffee', {}, (err, str) ->
        console.log err
        console.log str
        done()
      
      # thimble.compile(file) null, options, (err, str) ->
      #   throw err if err
      #   str.should.include 'console.log("cool")'
        
      
    it 'should compile handlebars', (done) ->
      file = fixtures + '/template.hb'
      options.locals = 
        planet : 'mars'
        
      thimble.compile(file) null, options, (err, str) ->
        throw err if err
        
        str.should.include "hello mars!"
        
        done()
        
    it 'should compile jade', (done) ->
      file = fixtures + '/post.jade'
      options = {}
      
      thimble.compile(file) null, options, (err, str) ->
        throw err if err
        
        str.should.include '<p>this is a post</p>'
        
        done()
        

      