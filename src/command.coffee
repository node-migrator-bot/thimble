path    = require "path"
args    = require("optimist").argv
action  = args._[0]
param = args._[1]
delete args._
delete args.$0
options = args

builder   = require "./builder"
utils = require "./utils"
fs      = require "fs"

# Command line options
switch action
  
  when "build"
    app = param
    options.public ||= "./public"
    options.root ||= path.dirname app
    options.build ||= "./build"
    
    # Work with absolute paths, so we don't have to deal with ./ui vs /ui vs ui edge cases
    app = path.resolve app
    options.public = path.resolve options.public
    options.root = path.resolve options.root
    options.env = "production"
    
    # Basically finds absolute path to build, then finds the relative path from root to app, so it
    # knows how many directories it needs to make once in build
    options.build = path.resolve(options.build) + "/" + utils.relativeFromRoot(options.root, app)
        
    builder.build app, options, (err, file) ->
      console.log "Successfully build the application:"
      console.log "#{app} --> #{file}"
