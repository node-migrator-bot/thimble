fs = require 'fs'
{normalize, resolve, exists} = require 'path'

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
  checks an arbitrary number of paths
###
check = exports.check = (paths = [], fn) ->
  finished = after(paths.length)
  found = false
  paths.forEach (path) ->
    exists path, (exist) ->
      if found then return
      else if exist
        found = true
        return fn(path)
      else if finished()
        return fn(false)

###
  Ensures the object contains the following keys
###

needs = exports.needs = (keys..., obj, fn) ->
  for key in keys
    if !obj[key]
      err = new Error('Error: object is missing the "' + key + '" key')
      if fn
        return fn(err)
      else
        throw err
  if fn
    return fn(null)

###
  Generates a relative path from a base to another file
###
relative = exports.relative = (from, to) ->

  trim = (arr) ->
    start = 0
    while start < arr.length
      break  if arr[start] isnt ""
      start++
    end = arr.length - 1
    while end >= 0
      break  if arr[end] isnt ""
      end--
    return []  if start > end
    arr.slice start, end - start + 1
    
  from = resolve(from).substr(1)
  to = resolve(to).substr(1)
  
  fromParts = trim(from.split("/"))
  toParts = trim(to.split("/"))
  
  length = Math.min(fromParts.length, toParts.length)
  
  samePartsLength = length
  i = 0

  while i < length
    if fromParts[i] isnt toParts[i]
      samePartsLength = i
      break
    i++
  outputParts = []
  i = samePartsLength

  while i < fromParts.length
    outputParts.push ".."
    i++
    
  outputParts = outputParts.concat(toParts.slice(samePartsLength))
  outputParts.join "/"

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