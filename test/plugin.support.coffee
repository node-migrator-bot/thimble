###
  Needs updating!
###

###
  Tests for the support plugin
###
fs = require 'fs'

should = require 'should'
cheerio = require 'cheerio'

thimble = require '../'

describe 'plugin', ->
  describe '.support', ->
    fixtures = __dirname + '/fixtures'
    options = 
      root : fixtures
      'support files' : []
    
    index = fs.readFileSync fixtures + '/index.html', 'utf8'
    
    it 'should not modify the content if no support files are present', (done) ->
      options['support path'] = __dirname + '/../support/'

      thimble.support index, options, (err, content) ->
        throw err if err

        content.should.equal(index)
        content.should.not.include ".registerHelper"
        
        done()
    
    it 'should append support script to the <head> by default', (done) ->
      # Add the support file
      options['support path'] = __dirname + '/../support/'
      options['support files'].push
        file : 'handlebars.js'
        options : {}
      
      thimble.support index, options, (err, content) ->
        throw err if err
        $ = cheerio.load content

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
    
    