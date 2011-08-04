{exec} = require 'child_process'

run = (command, callback) ->
  exec command, (err, stdout, stderr) ->
    console.warn stderr if stderr
    callback?() unless err

build = (callback) ->
  run 'coffee -co lib src', callback

install = (callback) ->
  run 'npm install -g', callback

watch = (callback) ->
  run 'coffee -wo lib src', callback
 
task "build", "Build lib/ from src/", ->
  build()
  
task "watch", "Watch and compile lib/ from src/", ->
  watch()
  
task "install", "Build and install the package", -> 
  build -> install ->
    console.log "Installed the application locally"