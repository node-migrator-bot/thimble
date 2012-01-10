###
  errors.coffee - an effort to provide more meaningful errors, without
  cluttering up the source code.
###

errors = 
  'no public directory' : '''
    In the production environment, you need to specify a 
    public directory where your assets will live
  '''
  
  'no build directory' : '''
    In the production environment, you need to specify
    a build directory to place your views
   '''
  
  'no root directory' : '''
    In the development environment, you need to specify
    a root directory where your application lives
  '''
  

module.exports = (err) ->
  if errors[err]
    return new Error(errors[err])
  else
    return new Error()
