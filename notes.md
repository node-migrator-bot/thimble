# Thimble Notes #

## Next up ##
* Write server tests
  * Should be trivial as all the wacky server code is gone :-)
* Start looking at providing "inserts", or compiled snippets. Markdown is a good place to start
* Install plugins programmatically as they come up using NPM
* Add support for image and other tags.
* Start writing documentation

## Testing to add ##

* Get *Original* Boilerplate working as a layout
* Implement server tests
  * Create a server
  * Start pounding it with GETs to assets and files

## Features recently added ##
* Rewrite command.coffee to use TJ's commander library.

### Eco Templating ###

Rendering will be easy, simply send back a compiled version. Build will require checking the type and prepending `JST["contact"] = [Function]` or something. Plan to tone down bundle's functionality to taking in a map or array, crushing it and writing it to disk. This will allow the flexibility to implement the templating. *Also* for templating, we will use the document plugins, and not the asset plugins.

## Features set on hold ##

### Globbing ###

**Problem:** Using globbing is not useful for development because files that have dependencies are arbitrarily selected from the filesystem. Going to leave in the globbing functionality in util.readFiles because it's badass and doesn't affect anything else.

### Middleware writes to public then static middleware renders ###
Major problem with this : You're now debugging JS/CSS and not the original language. Also will be slower writing. During development I don't see the benefits that static provides outweighing these issues. 