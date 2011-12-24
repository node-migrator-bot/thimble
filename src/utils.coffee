cache = {}

###
  ADD THIS TO EVERYTHING.
###

###
  Read function with caching
###
read = exports.read = (file, options, fn) ->
  str = cache[file]
  if str
    return fn(null, str)
    
  fs.readFile file, "utf8", (err, str) ->
    return fn(err) if err
    cache[file] = str
    fn null, str
    
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
    
module.exports = exports
