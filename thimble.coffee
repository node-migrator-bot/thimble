path = require "path"
args = require("optimist").argv
action = args._[0]
options = args._[1..]
lib = __dirname + "/lib"


if action is "server" or action is "serve"
  serverDir = path.resolve options[0] or "."
  serverPort = options[1] or 8080
  server = require "#{lib}/server.coffee"
  server.serve(serverDir, serverPort)
  
else if action is "build"
  buildDir = path.resolve options[0] or "."
  publicDir = path.resolve options[1] or "./public"
  options = options[2..] or {}
  builder = require "#{lib}/builder.coffee"
  builder.build buildDir, publicDir, options

