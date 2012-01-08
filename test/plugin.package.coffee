###
  Load Modules
###
fs = require 'fs'
{join} = require 'path'

should = require 'should'
cheerio = require 'cheerio'

fixtures = __dirname + '/fixtures'
public = __dirname + '/public'
build = __dirname + '/build'

thimble = require '../'

describe 'plugin', ->
  describe '.package', ->
    thim = undefined
    
    options =
      root   : fixtures
      public : public
      build  : build
      source : join fixtures, 'index.html'
    
    beforeEach (done) ->
      thim = thimble(options)
      thim.use thimble.package()
      done()
    
    it 'should create public and build directories', (done) ->
      html = """
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
      """
      
      thim.eval html, {}, (err, content) ->
        return done(err) if err
        
        
      
        done()