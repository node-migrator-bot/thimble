### Compile ###

Compile is used internally to render new languages. The compile plugin provides a unified interface for three different types of compilers. The plugin supports asset compilers, markup compilers, and template compilers. 

The asset compilers are used at the middleware layer and when we build our application. The supported compilers currently include [coffeescript](http://coffeescript.org/) and [stylus](http://learnboost.github.com/stylus/).

The markup compilers render non-HTML markup languages into HTML. The supported markup compilers include [markdown](http://daringfireball.net/projects/markdown/) and [jade](http://jade-lang.com/).

The template compilers are used for templating. The supported template compiler is [hogan](http://twitter.github.com/hogan.js/).

> **Note:** Performance is very important to thimble, so the template compilers are limited to HTML-like languages, because our HTML parser needs to understand their syntax. HTML-like languages include mustache and EJS languages.
