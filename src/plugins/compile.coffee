###
  Used to compile languages. If its a mustache template, compile it.
  If it's an underscore template, compile it.
###

exports = module.exports = (file) ->
  
  return (content, options, next) ->
    
    # Compile here