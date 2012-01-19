
###
  Embed.coffee - Used to embed templates into the document
###

{extname, basename, normalize} = require 'path'
fs = require 'fs'

cheerio = require 'cheerio'

thimble = require '../thimble'
utils = require '../utils'

support = __dirname + '/../../support'


exports = module.exports = (opts = {}) ->
  return embed

embed = exports.embed = (content, options, next) ->
  $ = cheerio.load content
  $scripts = $('script[type=text/template]')

  if !$scripts.length
    return next(null, content)
  else
    finished = utils.after $scripts.length
  
  $scripts.each ->
    $script = $(this)
    source = $script.attr('src')
    ext = extname source
    
    # Rename our template if we have an ID that's given
    name = $script.attr('id')
    name = if (name) then name else basename source, ext
    prefix = templatePrefix options, name
    
    ext = ext.substring 1

    # Map to known names
    ext = if (thimble.extensions[ext]) then thimble.extensions[ext] else ext
    
    # Get the precompiler 
    precompile = exports[ext]    
    
    assetPath = options.root + "/" + source

    if precompile
      precompile assetPath, options, (err, str) ->
        # Remove the attributes that will cause script not to execute
        $script.removeAttr('src')
               .attr('type', 'text/javascript')
        
        # Add the template information
        js = prefix + str
        
        # Attach it to the script tag
        $script.text(js)
                
        return next null, $.html()
        
    else if finished()
      return next null, $.html()
    
        
###
  Template Cache
###

cache = {};

###
  Requires Cache
###

requires = {};      

###
  Template variable generator
###

templatePrefix = (options, id) ->
  {namespace, template} = options
  return "\n#{namespace}.#{template} = #{namespace}.#{template} || {}; #{namespace}.#{template}['#{id}'] = "

###
  Read `file` with `options` with
  callback `(err, str)`. When `options.cache`
  is true the template string will be cached.  
###

read = (file, options, fn) ->
  str = cache[file]
  return fn(null, str)  if options.cache and str
  fs.readFile file, "utf8", (err, str) ->
    return fn(err)  if err
    cache[file] = str  if options.cache
    fn null, str
      
###
  Precompilers
###

exports.hogan = (file, options, fn) ->
  engine = requires.hogan || (requires.hogan = require('hogan.js'))
  filename = basename file, extname file
  out = []
  
  # Add the hogan.js support file
  options.support.push
    file : support + '/hogan.js'
    appendTo : 'head'
  
  read file, options, (err, str) ->
    return fn(err) if err

    out.push """
      (function() {
        var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
            tpl = new Hogan.Template(
    """

    out.push engine.compile(str, {asString : true})
    
    out.push """
        );
        return __bind(tpl.render, tpl);
      })();\n
    """
    
    fn(null, out.join('\n'))

 