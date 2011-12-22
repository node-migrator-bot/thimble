###
  Tests for the support plugin
###
fs = require 'fs'

thimble = require '../'
cheerio = require 'cheerio'

describe 'plugin', ->
  describe '.support', ->
    fixtures = __dirname + '/fixtures'
    options = 
      root : fixtures
      support : 
        files : []
    
    index = fs.readFileSync fixtures + '/index.html', 'utf8'
    
    it 'should append support script to the <head>', (done) ->
      # Add the support file
      options.support.files.push 'handlebars.js'
      
      thimble.support() index, options, (err, content) ->
        throw err if err
        $ = cheerio.load content
        
        $('head').find('script').length.should.equal 1
        content.should.include ".registerHelper"
        
        done()
    
    ###
      Not enough support files right now
    ###
    # it 'should ignore files that arent css or js files', (done) ->
    #   options.support.files.push 'style.styl'
    #   
    #   thimble.support() index, options, (err, content) ->        
    #     done(err)
    
    