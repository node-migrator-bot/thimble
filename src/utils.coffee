
read = exports.read = (file, options, fn) ->
  

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
