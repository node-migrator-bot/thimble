emitter = require('../thimble').emitter
languages = require('../language')('languages/')

emitter.on "after:flattened", ($) ->
  $scripts = $('script')
  
  $scripts.each ->
    $elem = $(this)
    
    if $elem.attr('type') is 'text/template'
      console.log $elem.html()
      compiler = languages($elem.attr('src')).compile
      console.log compiler
