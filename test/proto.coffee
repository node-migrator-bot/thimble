thimble = require '../'
fixtures = __dirname + '/fixtures'

describe 'proto', ->
  describe '.render', ->
    thim = thimble()
    
    it 'should render basic html correctly', (done) ->
      index = fixtures + '/index.html'

      thim.render index, {}, (err, content) ->
        throw err if err
        
        content.should.include.string "cool story, man."
        
        done()
        
    it 'should render with a layout', (done) ->
      layout = fixtures + '/layout.html'
      title = fixtures + '/title.html'
      
      thim.render title, { layout : layout }, (err, content) ->
        throw err if err
        
        content.should.include.string '<html>This is a pretty important title</html>'
        
        done()
        
    it 'should take allow a function as the 2nd parameter', (done) ->
      index = fixtures + '/index.html'
      
      thim.render index, (err, content) ->
        throw err if err
        
        content.should.include.string "cool story, man."
        
        done()
    
  describe '.configure', ->
    