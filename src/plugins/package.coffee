
###
  This is for packaging up the application into a view, a js file, and a css file
###

fs = require('fs')
{join, resolve, basename, dirname, extname} = require('path')

mkdirp = require('mkdirp')
cheerio = require('cheerio')

thimble = require('../thimble')
{after, relative, needs} = require('../utils')

public     = undefined
build      = undefined
directory  = undefined
view       = undefined
stylesheet = undefined
javascript = undefined

exports = module.exports = (opts = {}) ->
  
  return (content, options, next) ->
    needs 'public', 'build', 'source', 'root', options, (err) ->
      if err then return next(err)
      
    # Directories
    directory = relative(options.root, dirname(options.source))
    public    = join(options.public, directory)
    build     = join(options.build, directory)

    # Filenames
    ext  = extname(options.source)
    view = basename(options.source)
    base = basename(view, ext)

    stylesheet   = base + '.css'
    javascript   = base + '.js'

    # Set up the package directories
    setup (err) ->
      return next(err) if err
      
      todo = [
        'package css'
        'package js'
      ]
      
      finished = after todo.length
      
      $ = cheerio.load content
      
      done = (err) ->
        if err
          return next(err)
        else
          return next(null, content)
      
      packageJS $, (err) ->
        if finished()
          packageView($, done)
      
      packageCSS $, (err) ->
        if finished()
          packageView($, done)
      

    
setup = exports.setup = (fn) ->
  todo = [
    'make public directory'
    'make build directory'
  ]
  
  finished = after todo.length
  
  mkdirp public, 0755, (err) ->
    return fn(err) if err
    
    if finished()
      return fn(null, build, public)
      
  mkdirp build, 0755, (err) ->
    return fn(err) if err
    
    if finished()
      return fn(null, build, public)


###
  Package up the view
###        
packageView = exports.packageView = ($, fn) ->
  # if extname(view) is '.html'
  #   console.log view
    
  fn(null)

###
  Package up the JS
###
packageJS = exports.packageJS = ($, fn) ->
  $script = $('body').find('script')

  if !$script.length
    return fn(null)
  else
    # Write javascript file
    js = $script.text()
    $script.remove()
    path = join(public, javascript)
  
    fs.writeFile path, js, 'utf8', (err) ->
      if err
        return fn(err)
      else
        return fn(null)

###
  Package up the CSS
###
packageCSS = exports.packageCSS = ($, fn) ->
  $style  = $('head').find('style')
  
  if !$style.length
    return fn(null)
  else
    css = $style.text()

    # Remove style tag
    $style.remove()
    path = join(public, stylesheet)
    
    # Add a new link tag
    $link = $('<link>')
      .attr('type', 'text/css')
      .attr('href', '/' + stylesheet + "")
    
    # Write css file
    fs.writeFile path, css, 'utf8', (err) ->
      if err
        return fn(err)
      else
        return fn(null)
  
        