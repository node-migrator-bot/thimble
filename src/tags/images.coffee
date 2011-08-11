utils = require "../utils"
path = require "path"

build = exports.build = (assets, public, main, callback) ->
  directory = public + "/images/"
  
  # Pull out the sources and make them absolute
  sources = (main + "/" + elem.src for elem in assets) 
  finished = utils.countdown sources.length

  for asset in assets
    asset.src = "images/" + path.basename asset.src
    
  for source in sources
    utils.copy source, directory, (err) ->
      throw err if err
      
      if finished()
        callback null
        
module.exports = exports
