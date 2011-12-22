###
  Tests for the layout plugin
###
thimble = require '../'
fixture = __dirname + '/fixtures'

describe 'plugin', ->
  describe '.layout', ->
    
    it 'should place content within <yield /> tag', (done) ->
      layout = fixture + '/layout.html'
      options = {}
      
      thimble.layout(layout) 'hi there', options, (err, content) ->
        throw err if err

        content.should.include "<html>hi there</html>"

        done()