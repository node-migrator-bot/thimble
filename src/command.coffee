path    = require "path"
program = require "commander"
builder   = require "./builder"
utils = require "./utils"

if process.argv.length is 2
  process.argv.push "-h"

build = (app, program) ->
  app = path.resolve app
  options = {}
  options.root = program.rootDir or path.dirname(app)
  options.root = path.resolve options.root
  options.public = path.resolve program.publicDir
  options.build = path.resolve program.buildDir
  options.env = "production"
  
  if program.layout
    options.layout = path.resolve program.layout
    
  options.build = options.build + "/" + utils.relativeFromRoot(options.root, app)  
    
  builder.build app, options, (err, file) ->
    console.log "Successfully build the application:"
    console.log "#{app} --> #{file}"

program
  .version("0.0.1")
  .option("-l, --layout <path>", "Wrap application in a layout", false)
  .option("-p, --publicDir <path>", "Path to the public directory", "./public")
  .option("-r, --rootDir <path>", "Path to the root of your client-side code")
  .option("-b, --buildDir <path>", "Path to the build directory", "./build")

program
  .command("build <app>")
  .description("Build the client-side application")
  .action (app) ->
    build(app, program)
    
program.parse process.argv