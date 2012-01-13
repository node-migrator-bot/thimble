
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
      thim = thimble.create(options)
      done()
    
    it 'should compile stylus', (done) ->
      thim.render 'style.styl', {}, (err, str) ->
        return done(err) if err
        str.should.include 'color: #999;'
        done()
    
    it 'should compile coffeescript', (done) ->
      thim.render 'cool.coffee', {}, (err, str) ->
        return done(err) if err
        str.should.include 'return console.log("cool");'
        done()
      
    it 'should compile handlebars', (done) ->
      locals = 
        planet : 'mars'
        
      thim.render 'template.hb', locals, (err, str) ->
        return done(err) if err

        str.should.include "hello mars!"
        
        done()

    it 'should compile jade', (done) ->
      thim.render 'post.jade', {}, (err, str) ->
        return done(err) if err
        
        str.should.include '<p>this is a post</p>'
        
        done()
      
    it 'should compile markdown', (done) ->
      thim.use thimble.flatten()
      str = '<include src = "markdown.md" />'
      thim.eval str, {}, (err, str) ->
        return done(err) if err

        str.should.include "<h1>Header 1</h1>"
        str.should.include "<strong>hi there</strong>"
        str.should.include "<em>cool</em>"

        done()

      