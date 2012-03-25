###
  Tests for the layout plugin
###
thimble = require '../'
fixtures = __dirname + '/fixtures'

describe 'plugin', ->
  describe '.layout', ->
    
    options =
      root : fixtures
    
    beforeEach (done) ->
      thimble = thimble.create(options)
      done()
    
    it 'should place content within <yield /> tag', (done) ->
      str = 'hi there'
      options.layout = 'layout.html'
      
      thimble.eval str, options, (err, content) ->
        throw err if err

        content.should.equal "<html>hi there</html>"

        done()

    it 'should chain multiple layouts', (done) ->
      str = 'hi there'
      options.layout = ['layout.html', 'layout.html']

      thimble.eval str, options, (err, content) ->
        throw err if err
        content.should.equal "<html><html>hi there</html></html>"

        done()