# ** Used for both CSS and JS **
# DRY class for css and javascript files
# They both get merged together and moved

# Read Files, Render them if necessary, merges them, writes them to public

_ = require "underscore"
path = require "path"

utils = require "./utils"
plugin = require("./plugin")("./plugins/asset")
EventEmitter = require("events").EventEmitter
fs = require "fs"


class Bundler
  
  constructor : (@buildName, @public, @main) ->
    
  bundle : (assets, output) ->
    buildName = @buildName
    emitter = new EventEmitter()
    
    # Use the buildName to determine whether to use href (css) or src (js) attribute
    ext = path.extname(buildName).substring 1
    @attribute = if ext is "css" then "href" else "src"

    # Pull out the sources and make them absolute
    sources = []
    for elem in assets
      console.log elem[@attribute]
      if elem[@attribute]
        sources.push @main + "/" + elem[@attribute]
      
    # Set up the listeners
    emitter.once "read", (files) =>
      @render files, emitter
  
    emitter.once "rendered", (buildFile) =>
      buildFile = _.values(buildFile).join "\n"
      @write buildFile, @public, emitter
    
    emitter.once "written", (buildPath) =>
      @modify assets, emitter

    emitter.once "modified", ->
      output null

    @read sources, emitter

  read : (assets, emitter) ->  
    utils.readFiles assets, (err, files) ->
      throw err if err
      emitter.emit "read", files

  render : (files, emitter) ->
    buildFile = utils.toKeys _.keys files
    finished = utils.countdown _.size(buildFile)
  
    for file, code of files
      p = plugin(file)

      if p
        p.render code, file, (err, code) ->
          buildFile[file] = code
          if finished()
            emitter.emit "rendered", buildFile
      else
        buildFile[file] = code  
        if finished()
          emitter.emit "rendered", buildFile  

  # Writes the filestream to a given location
  write : (content, to, emitter) ->
    fullPath = to + "/" + @buildName
  
    fs.writeFile fullPath, content, "utf8", (err) ->
     throw err if err
     emitter.emit "written", fullPath

  # Modify the DOMElements to replace 
  modify : (assets, emitter) ->
    assetsLength = assets.length
  
    # output = utils.fillArray assetLength, null
    for asset, i in assets
      if i is assetsLength - 1
        asset[@attribute] = @buildName
      else
        asset.parentNode.removeChild(asset) if asset.parentNode
        
    # output[assetLength-1] = asset
    
    emitter.emit "modified"
  

module.exports = (buildName, publicDir, mainDir) ->
  return new Bundler buildName, publicDir, mainDir