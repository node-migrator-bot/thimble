path = require "path"
args = require("optimist").argv
action = args._[0]
options = args._[1..]
lib = __dirname + "/lib"
build = require("#{lib}/builder.coffee")

if action is "server" or action is "serve"
  serverDir = path.resolve options[0] or "."
  serverPort = options[1] or 8080
  server = require "#{lib}/server.coffee"
  server.serve(serverDir, serverPort)
  
else if action is "build"
  appPath = path.resolve options[0] or "."
  publicDir = path.resolve options[1] or "./public"
  options = options[2..] or {}
  options.root = appPath
  builder = new build(appPath, publicDir, options)
  builder.build (err, html) ->
    throw err if err
    console.log html

