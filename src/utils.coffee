
# Pretty elegant counter
after = exports.after = (length) ->
  left = length
  return ->
    left--
    if left <= 0
      return true
    else
      return false

timer = exports.timer = (name) ->
  @name = name

timer::start = ->
  @start = Date.now()

timer::stop = ->
  @stop = Date.now()

timer::results = ->
  "Results #{@name} : " + (@stop - @start) + "ms"  

module.exports = exports