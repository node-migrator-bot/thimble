# This is the patch for jsdom to allow for new elements to be defined

tags = require("./tags/tags").patches

loadPatches = () ->
  HTMLElements = {}
  for name, attributes of tags
    key = "HTML" + name[0].toUpperCase() + name.slice(1) + "Element"
    HTMLElements[key] = 
      tagName : name.toUpperCase()
    
    for attribute, value of attributes
      HTMLElements[key][attribute] = value
  
  return HTMLElements
  
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
        

patch = module.exports = (jsdom) ->
  HTMLElements = loadPatches()
  core = exports.core = jsdom.dom.level3.core
  
  for elem, attributes of HTMLElements
    define elem, attributes

  return jsdom
