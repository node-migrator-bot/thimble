###
  Load Modules
###
fs = require 'fs'
{join, existsSync, dirname} = require 'path'

should = require 'should'
cheerio = require 'cheerio'

fixtures = __dirname + '/fixtures'
public = __dirname + '/public'
build = __dirname + '/build'
rm = require 'rimraf'

read = (file) ->
  return fs.readFileSync file, 'utf8'
  
exists = (path) ->
  return existsSync(path)

html = """
<html>
  <head>
    <style type = "text/css">
      h2 { color : black }
    </style>
  </head>
  <body>
    hi there
    <script type = "text/javascript">
      alert('hi world');
    </script>
  </body>
</html>
"""

thimble = require '../'

describe 'plugin', ->
  describe '.package', ->
    
    options =
      root   : fixtures
      public : public
      build  : build
      source : join fixtures, 'index.html'
    
    beforeEach (done) ->
      thimble = thimble.create(options)
      
      # Add the plugin
      thimble.use thimble.package()
      
      done()
    
    afterEach (done) ->
      rm.sync public
      rm.sync build
      done()
    
    it 'should create public and build directories', (done) ->
      thimble.eval html, {}, (err, content) ->
        return done(err) if err

        exists(build).should.be.ok
        exists(public).should.be.ok

        done()
        
    it 'should create app directories ex. build/index', (done) ->
      thimble.set 'source', join fixtures, 'index/index.html'
      
      thimble.eval html, {}, (err, content) ->
        return done(err) if err
    
        b = join build, 'index'
        p = join public, 'index'
    
        exists(b).should.be.ok
        exists(p).should.be.ok
      
        done()
    
    it 'should write css file to public directory', (done) ->
      thimble.set 'source', join fixtures, 'index/index.html'
      
      p = join public, 'index/index.css'
    
      thimble.eval html, {}, (err, content) ->
        return done(err) if err
      
        exists(p).should.be.ok

        css = read(p)
        css.should.include "color : black"
        
        done()
        
    it 'should write js file to public directory', (done) ->
      thimble.set 'source', join fixtures, 'index/index.html'
      
      p = join public, 'index/index.js'
      
      thimble.eval html, {}, (err, content) ->
        return done(err) if err
      
        exists(p).should.be.ok

        js = read(p)
        js.should.include "alert('hi world');"
        
        done()
        
    it 'should write view file to build directory', (done) ->
      # Use arbitrary source that is one directory deep
      thimble.set 'source', join fixtures, 'index/index.html'
      
      b = join build, 'index/index.html'
      
      thimble.eval html, {}, (err, content) ->
        return done(err) if err

        exists(b).should.be.ok

        v = read(b)
        v.should.include '/index/index.css'
        v.should.include 'hi there'
        v.should.include '/index/index.js'

        done()
        
    it 'should write images to public directory', (done) ->
      thimble.set 'source', join fixtures, 'index.html'
      
      html = "<img src = 'chameleon.jpg' />"
      
      img = join public, 'chameleon.jpg'
      b = join build, 'index.html'
      
      thimble.eval html, {}, (err, content) ->
        return done(err) if err

        exists(img).should.be.ok
        exists(b).should.be.ok

        view = read(b)
        view.should.include '/chameleon.jpg'

        done()
      
      
      
      