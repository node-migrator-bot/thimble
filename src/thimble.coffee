
###
  thimble.coffee is the main driver
###
fs = require "fs"
{basename, extname, normalize, resolve, join} = require "path"

_ = require "underscore"

error = require('./error')

# Load all the static functions (plugins)
exports = require './static'

###
  Public: Set options. May also be called by thimble(...)
###
exports.set = (key, value) ->
  if !key
    return this
  else if _.isObject(key)
    this.settings = _.extend this.settings, key
  else if value
    this.settings[key] = value
    
  return this

###
  Public: Get options
###
exports.get = (key) ->
  return this.settings[key]

###
  Public: creates a thimble instance. Sets up the object and 
    passes in the configuration

  configuration - configuration values for the server

  Examples

    var t = thimble.create({
      root : "./client",
      env : "production",
      paths : {
        support : "./client/support"
        vendor : "./client/vendor"
      }
    });

  Returns: an thimble instance Object 
###  
exports.create = (options = {}) ->
  # Set the default function to setting options
  # Need to bind it, to have thimble scope
  thimble = (options = {}) ->
    return thimble.set(options)
    
  thimble.stack = []
  # Clone to make sure changes in outside options don't interfere
  thimble.settings = _.clone(options)

  # Get the env from how $ node is run
  env = process.env.NODE_ENV || 'development'
  
  # Set the defaults
  _.defaults thimble.settings,
    env : env
    paths : {}
    template : 'JST'
    namespace : 'window'
    support : []
    
    # Shouldn't be needed
    instance : thimble

  
  # thimble.__proto__ = require './proto'
  thimble.__proto__ = exports
  
  return thimble

###
  Public: plug in the plugins that will be called as the content moves
    through the layers. Can be chained.

  fn - a plugin Function

  Examples

    t.use(thimble.focus());

    t.use(thimble.bundle('./public'))

  Returns an instance of the thimble Object
###
use = exports.use = (fn) ->
  this.stack.push fn
  return this

###
  Public: Allow thimble to add support files to application
###

insert = exports.insert = (file, appendTo = 'head') ->
  this.settings.support.push
    file : file
    appendTo : appendTo
  
  return this


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
  self = this
  envs = "all"
  args = [].slice.call(arguments)
  fn = args.pop()
  
  envs = args if args.length
  if "all" is envs or ~envs.indexOf(self.settings.env)
    fn.call self, (plugin) ->
      self.use(plugin)

  return this

###
  Public: starts thimble and configures our server

  app - the server we created in express -- ie. app = express.createServer()
###
start = exports.start = (app) ->
  server = require "./server"
  server.start.call this, app
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
render = exports.render = (file, locals = {}, fn) ->
  # If nothing is set, don't do anything
  if !locals and !fn
    return;

  self = this
  options = self.settings

  if !options.root
    err = error('no root directory')
    return fn(err)

  # Obtain the source, and add it to the settings
  options.source = join(options.root, file)

  fs.readFile options.source, "utf8", (err, content) ->
    return fn(err) if err

    eval.call self, content, locals, fn

  return this
  
###
  Public: Evaluate a string
###
eval = exports.eval = (content, locals = {}, fn) ->
  # If nothing is set, don't do anything
  if !locals and !fn
    return;

  self = this
  options = self.settings

  if !options.root
    err = error('no root directory')
    return fn()

  # Save the original stack so we don't change it everytime we eval
  # with a layout
  stack = _.clone(self.stack)

  # Allow fn to be passed as the 2nd param
  if('function' is typeof locals)
    fn = locals
    locals = {}

  # If theres a layout, add the layout plugin
  if locals.layout
    options.layout = join(options.root, locals.layout)
    # Add to the top of the stack
    self.stack.unshift self.layout()

  # If there's support files, add them
  self.stack.push self.support()

  # Compile the template at the end
  # This should be moved into thim.configure 'dev'
  if options.source
    self.stack.push self.compile(options.source, locals)

  # Kick off the plugins
  handle.call self, content, options, (err, output) ->
    self.stack = stack
    return fn(err, output)

  return this

###
  Private: Handle the plugin layers
###
handle = (content, options, out) ->
  self = this
  stack = self.stack
  index = 0

  next = (err, content) ->
    # Next callback
    layer = stack[index++]

    # all done
    if (!layer)
      if out then return out(err, content)

    # Plugin punting
    try
      arity = layer.length
      if err
        # Give the middleware a chance to catch it
        if arity is 4
          layer(err, content, options, next)
        else
          next(err)
      else if arity < 4
        layer(content, options, next)
      else
        next()
    catch e
      next(e)

  # Kick it off
  next(null, content)

###
  Hook static application modules onto thimble object
###

module.exports = exports.create()

