# This is the patch for jsdom to allow for new elements to be defined



HTMLElements = 
  "HTMLEmbedElement" :
    tagName : "EMBED"
    attributes : [
      "src",
      "type"
    ]

exports.domManip = (jQuery) ->
  rchecked = /checked\s*(?:[^=]|=\s*.checked.)/i
  (args, table, callback) ->
    value = args[0]
    scripts = []
    if not jQuery.support.checkClone and arguments.length == 3 and typeof value == "string" and rchecked.test(value)
      return @each(->
        jQuery(this).domManip args, table, callback, true
      )
    if jQuery.isFunction(value)
      return @each((i) ->
        self = jQuery(this)
        args[0] = value.call(this, i, (if table then self.html() else undefined))
        self.domManip args, table, callback
      )
    if this[0]
      parent = value and value.parentNode
      if jQuery.support.parentNode and parent and parent.nodeType == 11 and parent.childNodes.length == @length
        results = fragment: parent
      else
        results = jQuery.buildFragment(args, this, scripts)
      fragment = results.fragment
      if fragment.childNodes.length == 1
        first = fragment = fragment.firstChild
      else
        first = fragment.firstChild
      if first
        table = table and jQuery.nodeName(first, "tr")
        i = 0
        l = @length
        lastIndex = l - 1
    
        while i < l
          callback.call (if table then root(this[i], first) else this[i]), (if results.cacheable or (l > 1 and i < lastIndex) then jQuery.clone(fragment, true, true) else fragment)
          i++
          
    this

patch = exports.patch = (jsdom) ->
  core = exports.core = jsdom.dom.level3.core
  
  for elem, attributes of HTMLElements
    define elem, attributes

  return jsdom.jsdom
  
  
define = exports.define = (elementClass, def) ->
  core = exports.core
  tagName = def.tagName
  tagNames = def.tagNames or if tagName then [tagName] else []
  parentClass = def.parentClass or core.HTMLElement
  attrs = def.attributes or []
  proto = def.proto or {}
  
  elem = core[elementClass] = (document, name) ->
    parentClass.call(this, document, name or tagName.toUpperClass())
    if elem._init
      elem._init.call(this)
      
  elem._init = def.init
  elem.prototype = proto
  elem.prototype = __proto__ = parentClass.prototype
  
  attrs.forEach (n) ->
    prop = n.prop or n
    attr = n.attr or prop.toLowerCase()
    
    if not n.prop or n.read isnt false
      elem.prototype.__defineGetter__ prop, () ->
        s = this.getAttribute attr
        
        if n.type and n.type is 'boolean'
          return !!s
        
        if n.type and n.type is 'long'
          return +s
        
        if n.normalize
          return n.normalize s

        return s
    
    if not n.prop or n.write isnt false
      elem.prototype.__defineSetter__ prop, (val) ->
        if not val
          this.removeAttribute attr
        else
          s = val.toString()
          if n.normalize
            s = n.normalize s
          this.setAttribute attr, s
        
        

module.exports = exports
