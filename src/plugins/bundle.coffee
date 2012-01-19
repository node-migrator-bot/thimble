
###
  Load Modules
###

{join} = require('path')

cheerio = require('cheerio')

thimble = require('../thimble')
{after, read} = require('../utils')

###
  Used to bundle up the assets into single <script> and <style> tags
###

exports = module.exports = (opts = {}) ->
  # Prefer to be on the bottom
  return (content, options, next) ->
    options.instance.use(bundle(opts))
    next(null, content)
      
bundle = exports.bundle = (opts = {}) ->   
  return (content, options, next) ->
    $ = cheerio.load content

    scripts = []
    styles = []

    # Cache external selectors
    $scripts = $('script[type="text/javascript"]')
    $styles = $('link, style')

    # We need to know how many assets to wait for.
    assets = $scripts.length + $styles.length
    finished = after(assets)
    
    done = () ->      
      # Style tag
      style = $('<style>')
        .attr('type', 'text/css')
        .text(styles.join('\n'))
      
      # Script tag
      script = $('<script>')
        .attr('type', 'text/javascript')
        .text(scripts.join(';\n'))
            
      # Append the <style> tag to <head>
      head = $('head')
      if styles.length and head.length
        $('head').append(style)
      else
        # Figure out later
      
      # Append the <script> tag to <body>
      body = $('body')
      if scripts.length and body.length
        $('body').append(script)
      else
        # Figure out later
    
      return next(null, $.html())
    
    # Bring in all the scripts
    $scripts.each (i) ->
      $script = $(this)
      src = $script.attr('src')
      
      # skip http://
      if src and ~src.indexOf 'http://'
        if finished() then return done() else return
      
      # Remove the script tag
      $script.remove()
      
      # Read and compile if external
      if src
        compile src, options, (err, str) ->
          return next(err) if err
          
          # Add to array
          scripts[i] = str
          
          if finished()
            return done()
            
      # Otherwise just add it
      else
        scripts[i] = $script.text()
        
        if finished()
          return done()
          
    # Bring in all the css
    $styles.each (i) ->
      $style = $(this)
      href = $style.attr('href')

      # skip http://
      if href and ~href.indexOf 'http://'
        if finished() then return done() else return
      
      # Remove the style tag
      $style.remove()
      
      # Read and compile if external
      if href
        compile href, options, (err, str) ->
          return next(err) if err
          
          styles[i] = str
          
          if finished()
            return done()
            
      # Otherwise just add it
      else
        styles[i] = $style.text()
        
        if finished()
          return done()
        
###
  Compiles the assets
###
compile = (source, options, fn) ->
  path = join(options.root, source)
  read path, (err, str) ->
    return fn(err) if err
    
    thimble.compile(source) str, options, (err, str) ->
      return fn(err) if err
      fn(null, str)
      
  