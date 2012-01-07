
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
      
      # Remove all the assets from the page
      $('link, style').remove()
      $('script[type="text/javascript"]').remove()
      
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
      if head.length
        $('head').append(style)
      else
        # Figure out later
      
      # Append the <script> tag to <body>
      body = $('body')
      if body.length
        $('body').append(script)
      else
        # Figure out later
    
      return next(null, $.html())
    
    # Bring in all the scripts
    $scripts.each (i) ->
      $script = $(this)
      src = $script.attr('src')

      if src
        compile src, options, (err, str) ->
          return next(err) if err
          
          # Add to array
          scripts[i] = str
          
          if finished()
            return done()
      else
        scripts[i] = $script.text()
        
        if finished()
          return done()
          
    # Bring in all the css
    $styles.each (i) ->
      $style = $(this)
      href = $style.attr('href')
      
      if href
        compile href, options, (err, str) ->
          return next(err) if err
          
          styles[i] = str
          
          if finished()
            return done()
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
      
  