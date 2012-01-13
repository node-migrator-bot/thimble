###
  errors.coffee - an effort to provide more meaningful errors, without
  cluttering up the source code.
###

errors = 
  'no public directory' : '''
    Error: In the production environment, you need to 
    specify a public directory where your assets will live
  '''
  
  'no build directory' : '''
    Error: In the production environment, you need to
    specify a build directory to place your views
   '''
  
  'no root directory' : '''
    Error: In the development environment, you need to
    specify a root directory where your application lives
  '''
  
  'cannot find source' : '''
    Error: Cannot find the source directory, tried relative to 
    the current working directory, and tried relative to the root
  '''
  

module.exports = (err) ->
  if errors[err]
    return new Error(errors[err])
  else
    return new Error()
