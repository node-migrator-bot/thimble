###
  Embed.coffee - Used to embed templates into the document
###

path = require "path"
fs = require "fs"

cheerio = require "cheerio"

thimble = require "../thimble"
utils = require "../utils"

support = __dirname + '/../../support'

exports = module.exports = (content, options, next) ->
  $ = cheerio.load content
  $scripts = $('script[type=text/template]')
  
  if !$scripts.length
    return next(null, content)
  else
    
  finished = utils.countdown $scripts.length
  $scripts.each ->
    $script = $(this)
    source = $script.attr('src')
    extname = path.extname source
    
    # Rename our template if we have an ID that's given
    name = $script.attr('id')
    name = if (name) then name else path.basename source, extname
    prefix = templatePrefix options, name
    
    extname = extname.substring 1

    # Map to known names
    extname = if (thimble.extensions[extname]) then thimble.extensions[extname] else extname
    
    # Get the precompiler 
    precompile = exports[extname]    
    
    assetPath = options.root + "/" + source
    
    if precompile
      
      precompile assetPath, options, (err, str) ->
        
      
        $script.removeAttr('src')
               .attr('type', 'text/javascript')
        
        js = prefix + str

        $script.text(js)
        
        ###
          CLEAN UP
        ###
        # Check to see if there is a support file
        read support + '/' + extname + '.js', options, (err, str) ->
          if !err
            $('head').append $('<script>').text(str)
          
          if finished()
            next null, $.html()
        
    else if finished()
      next null, $.html()
    
        
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

exports.handlebars = (file, options, fn) ->
  engine = requires.handlebars || (requires.handlebars = require('handlebars'))
  basename = path.basename file, path.extname file
  out = []

  

  read file, options, (err, str) ->

    out.push """
      (function() {
        var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
        templates['#{basename}'] = template(
    """

    out.push engine.precompile str
  
    out.push """
      );
    })();\n
    """

    fn null, out.join '\n'

 