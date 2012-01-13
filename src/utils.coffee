fs = require 'fs'
{normalize} = require 'path'

cache = {}

###
  ADD THIS TO EVERYTHING.
###

###
  Read function with caching
###
read = exports.read = (file, fn) ->
  # Should be cached in production, not dev
  # str = cache[file]
  # if str
  #   return fn(null, str)
  fs.readFile file, "utf8", (err, str) ->
    return fn(err) if err
    cache[file] = str

    fn(null, str)
    
###
  Counter used for async calls
###
after = exports.after = (length) ->
  left = length
  return ->
    left--
    if left <= 0
      return true
    else
      return false

###
  Ridiculously simple timer
###
timer = exports.timer = (name) ->
  
  name : name
  startTime : 0
  stopTime : 0
  
  start : ->
    @startTime = Date.now()
  
  stop : ->
    @stopTime = Date.now()

  results : ->
    "Results #{@name} : " + (@stopTime - @startTime) + "ms"  
    
###
  Finds the path relative to another
###
relative = exports.relative = (directory, base) ->
  directory = normalize directory
  base      = normalize base

  dir = directory.split "/"
  b = base.split "/"

  for d, i in dir
    if b[i] isnt d
      return dir.slice(i).join('/')

  return ""

###
  Tiny, but flexible step library
###
step = exports.step = () ->
  stack = Array.prototype.slice.call(arguments).reverse()
  self = this
  
  next = () ->
    args = Array.prototype.slice.call(arguments)
    if stack.length > 1
      args.push next
    stack.pop().apply(self, args)

  stack.pop().call(self, next)

module.exports = exports