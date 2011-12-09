###
  Public: starts thimble and configures our server
  
  app - the server we created in express -- ie. app = express.createServer()
###
start = exports.start = (app) ->
  server = require "./server"
  server.start.call this, app

###
  Public: configure the application for zero or more callbacks.
  When there is no environment present, it will be invoked for
  all the environments. Any combination can be used multiple
  times and in any order.
  
  env, ... - a splat of String environments to run this configuration on
  fn - configuration Function to invoke when environment is
  
  Examples
  
    t.configure(function(){
      // executed for all envs
    });

    t.configure('stage', function(){
      // executed staging env
    });

    t.configure('stage', 'production', function(){
      // executed for stage and production
    });
  
  Returns an instance of the thimble Object
###

configure = exports.configure = (env, fn) ->
  envs = "all"
  args = [].slice.call(arguments)
  fn = args.pop()
  
  envs = args if args.length
  if "all" is envs or ~envs.indexOf(this.settings.env)
    fn.call this
  
  return this

###
  Public: plug in the plugins that will be called as the content moves
    through the layers
  
  fn - a plugin Function
  
  Examples
  
    t.use(thimble.focus());
    
    t.use(thimble.bundle('./public'))
  
  Returns an instance of the thimble Object
###
use = exports.use = (fn) ->
  this.stack.push
    handle: fn

  return this

###
  Public: renders the application
  
  file - a String that is the main entry point into our application
  locals - a local variable Object containing parameters to pass through
    to the templates. Locals may contain a `layout` key, which will use the 
    value as a base layout
  fn - a callback Function invoked when render completes. First parameter is
    an `err` variable, second is the content. 
    
  Examples
    
    t.render("app.html", { planet : "world" }, function(err, content) {
      if(err) throw err;
      // Content is here.
    });
    
  
###
render = exports.render = (file, locals, fn) ->
  this.settings.source = file

###
  Private: Handle the plugin layers
  
###
handle = (content, options, out) ->
  stack = this.stack
  



module.exports = exports