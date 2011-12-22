
thimble = require '../'
should = require 'should'

describe 'plugin', ->
  describe '.compile', ->
    
    fixtures = __dirname + '/fixtures'
    options = 
      root : fixtures
      
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
    
      thimble.compile(file) null, options, (err, str) ->
        throw err if err
        str.should.include 'console.log("cool")'
        
        done()
      
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
        

      