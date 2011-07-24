# ** Used for both CSS and JS **
# DRY class for css and javascript files
# They both get merged together and moved

# Read Files, Render them if necessary, merges them, writes them to public

_ = require "underscore"
path = require "path"

lib = "#{__dirname}/.."
utils = require "#{lib}/utils.coffee"
plugin = require "#{lib}/plugin.coffee"
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
fs = require "fs"



bundle = exports.bundle = (assets, public, main, output) ->
  buildName = exports.buildName

  # Use the buildName to determine whether to use href (css) or src (js) attribute
  ext = path.extname(buildName).substring 1
  attribute = exports.attribute = if ext is "css" then "href" else "src"

  # Pull out the sources and make them absolute
  sources = (main + "/" + elem[attribute] for elem in assets) 

  # Set up the listeners
  emitter.once "read", (files) ->
    render files, emitter
  
  emitter.once "rendered", (buildFile) ->
    buildFile = _.values(buildFile).join "\n"
    write buildFile, public, emitter
    
  emitter.once "written", (buildPath) ->
    modify assets, emitter

  emitter.once "modified", (assets) ->
    output null, assets

  read sources, emitter

read = exports.read = (assets, emitter) ->  
  utils.readFiles assets, (err, files) ->
    throw err if err
    emitter.emit "read", files

render = exports.render = (files, emitter) ->
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
write = exports.write = (content, to, emitter) ->
  fullPath = to + "/" + exports.buildName
  
  fs.writeFile fullPath, content, "utf8", (err) ->
   throw err if err
   emitter.emit "written", fullPath

# Modify the DOMElements to replace 
modify = exports.modify = (assets, emitter) ->
  assetLength = assets.length
  attribute = exports.attribute
  
  out = utils.fillArray assetLength, null

  asset = _.last assets
  console.log exports.buildName
  console.log asset[attribute]
  asset[attribute] = exports.buildName
  console.log asset[attribute]

  

module.exports = (buildName) ->
  exports.buildName = buildName
  return exports