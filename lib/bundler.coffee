# DRY class for css and javascript files
# They both get merged together and moved

# Read Files, Render them if necessary, merge them, write them

_ = require "underscore"
path = require "path"

lib = "#{__dirname}"
utils = require "#{lib}/utils.coffee"
plugin = require "#{lib}/plugin.coffee"
EventEmitter = require("events").EventEmitter
emitter = new EventEmitter()
fs = require "fs"

bundle = exports.bundle = (assets, public, callback) ->

  emitter.once "read", (files) ->
    render files, emitter
  
  emitter.once "rendered", (buildFile) ->
    buildFile = _.values(buildFile).join "\n"
    write buildFile, public, emitter
    
  emitter.once "written", (buildPath) ->
    callback null, buildPath
    
  read assets, emitter

read = exports.read = (assets, emitter) ->
  buildFile = utils.toKeys assets
  finished = utils.countdown assets.length
  
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

merge = exports.merge = (files, emitter) ->
  

# Writes the filestream to a given location
write = exports.write = (content, to, emitter) ->
  fullPath = to + "/" + exports.buildName
  
  fs.writeFile fullPath, content, "utf8", (err) ->
   throw err if err
   emitter.emit "written", fullPath

module.exports = (buildName) ->
  exports.buildName = buildName
  return exports