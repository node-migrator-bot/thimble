
###
  This is for packaging up the application into a view, a js file, and a css file
###

fs = require('fs')
{join, resolve, basename, dirname, extname} = require('path')

_ = require('underscore')
cheerio = require('cheerio')

thimble = require('../thimble')
{after, relative, needs, mkdirs, step, copy} = require('../utils')

exports = module.exports = (opts = {}) ->
  # Prefer to be on the bottom
  return (content, options, next) ->
    options.instance.use(package(opts))
    next(null, content)

package = exports.package = (opts = {}) ->
  return (content, options, next) ->
    needs 'public', 'build', 'source', 'root', options, (err) ->
      if err then return next(err)

    # Directories
    directory = relative(options.root, dirname(options.source))
    public    = join(options.public, directory)
    build     = join(options.build, directory)
    
    # Filenames
    ext  = extname(options.source)
    file = basename(options.source)
    base = basename(file, ext)

    # Asset names
    stylesheet   = base + '.css'
    javascript   = base + '.js'

    opts = _.extend opts,
      directory : directory
      public : public
      build : build
      ext : ext
      view : file
      base : base
      stylesheet : stylesheet
      javascript : javascript
      root : options.root
      
    $ = cheerio.load content
    
    before = (next) ->
      mkdirs public, build, (err) ->
        next(err, $, opts)

    done = (err) ->
      next(err, content)

    # Run through the following steps in series
    step before, images, css, js, view, done

###
  Package images
###

images = exports.images = (err, $, opts, next) ->
  return next(err) if err
  
  {public, directory, root} = opts
  $imgs = $('img')

  if !$imgs.length
    return next(null, $, opts)
  else
    finished = after($imgs.length)
    
  path = join(public, directory)

  $imgs.each ->
    $img = $(this)
    source = $img.attr('src')
    asset = join('/', directory, source)
    $img.attr('src', asset)
    console.log $.root.children[0]
    # Copy file over to public
    src  = join(root, asset)
    dest = join(public, asset)

    copy src, dest, (err) ->
      if err
        return next(err) 
      else if finished()
        return next(null, $, opts)
        
###
  Package the css
###
css = exports.css = (err, $, opts, next) ->
  return next(err) if err

  $style  = $('head').find('style')
  {public, directory, stylesheet} = opts

  if !$style.length
    return next(null, $, opts)

  # Get text and trim it
  str = $style.text().trim()

  # Remove style tag
  $style.remove()
  
  # Add stylesheet to public folder
  path = join(public, stylesheet)
  public = join(directory, stylesheet)

  # Add a new link tag
  $link = $('<link>')
    .attr('type', 'text/css')
    .attr('href', '/' + public)
    .attr('rel', 'stylesheet')
    
  $('head').append($link)
  
  # Write css file
  fs.writeFile path, str, 'utf8', (err) ->
    return next(err, $, opts)

###
  Package the javascript
###

js = exports.js = (err, $, opts, next) ->
  return next(err) if err
  
  $script = $('script')
  {public, directory, javascript} = opts

  if !$script.length
    return next(null, $, opts)

  # Get text and trim it
  str = $script.text().trim()
  
  # Remove javascript tag
  $script.remove()
  
  # Add javascript to public
  path = join(public, javascript)
  public = join(directory, javascript)

  # Add a new script tag
  $script = $('<script>')
    .attr('type', 'text/javascript')
    .attr('src', '/' + public)
    
  $('body').append($script)

  # Write the js file
  fs.writeFile path, str, 'utf8', (err) ->
    return next(err, $, opts)
  
###
  Package the view
###

view = exports.view = (err, $, opts, next) ->
  return next(err) if err
  
  {build, ext} = opts
  file = opts.view

  path = join(build, file)
  content = $.html()

  fs.writeFile path, content, 'utf8', next
