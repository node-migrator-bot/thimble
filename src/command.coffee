path    = require "path"
args    = require("optimist").argv
action  = args._[0]
options = args._[1..]
build   = require "./builder"
fs      = require "fs"

# Command line options
switch action
  when "server", "serve"
    if !options[0]
      console.error "Need to specify a directory to serve from (eg. /ui)"
      process.exit 1
    serverDir = path.resolve options[0]
    serverPort = options[1] or 8080
    server = require "./server"
    server.serve(serverDir, serverPort)
  
  when "build"
    appPath = path.resolve options[0] or "."
    publicDir = path.resolve options[1] or "./public"
    options = options[2..] or {}
    options.root = appPath
    builder = new build(appPath, publicDir, options)
    builder.build (err, html) ->
      throw err if err
      fs.writeFile publicDir + "/build.html", html, "utf8", (err) ->
        throw err if err
        console.log "Successfully built #{appPath}"
