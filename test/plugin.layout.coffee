
###
  Tests for the layout plugin
###
thimble = require '../'
fixtures = __dirname + '/fixtures'

describe 'plugin', ->
  describe '.layout', ->
    thim = undefined
    
    options =
      root : fixtures
    
    beforeEach (done) ->
      thim = thimble.create(options)
      thim.use thimble.layout
      done()
    
    it 'should place content within <yield /> tag', (done) ->
      str = 'hi there'
      options.layout = 'layout.html'
      
      thim.eval str, options, (err, content) ->
        throw err if err

        content.should.include "<html>hi there</html>"

        done()