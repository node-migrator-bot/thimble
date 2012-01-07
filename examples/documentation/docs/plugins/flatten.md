### Flatten ###

Flatten introduces the `include` tag to your HTML. By using flatten you can modularize your web application and break free from traditional directory structures. Flatten allows you to include HTML from your HTML. The following is an example of including `menu.html`:

    <include src = "menu.html" />

Flatten also supports languages that compile into HTML. Currently, thimble has compilers for [markdown](http://daringfireball.net/projects/markdown/) and [jade](http://jade-lang.com/), allowing you to write: 

    <include src = "intro.md" />
    <include src = "body.jade" />

The most important feature of flatten is that __paths become relative to included file's directory__. This allows you to have a directory structure like:

__app/__
&nbsp;&nbsp;&nbsp;• app.html
&nbsp;&nbsp;&nbsp;__menu/__
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• menu.html
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• menu.css

Then in `app.html`:

    <include src = "menu/menu.html" />
    
And then do the following in `menu.html`:

    <link href = "menu.css" />
    
This feature allows you to focus on one piece of your application, without worrying about the directory structure outside.