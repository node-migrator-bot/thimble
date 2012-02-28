### Flatten ###

Flatten introduces the `include` tag to your HTML. By using flatten you can modularize your web application and break free from traditional directory structures. Flatten allows you to include HTML from your HTML. The following is an example of including `menu.html`:

    <include src = "menu.html" />

Flatten also supports markup languages that compile into HTML. Currently, thimble has compilers for [markdown](http://daringfireball.net/projects/markdown/) and [jade](http://jade-lang.com/), allowing you to write: 

    <include src = "intro.md" />
    <include src = "body.jade" />

> **Note:** thimble does not support jade local variables

The most important feature of flatten is that __paths become relative to the included file's directory__. This allows you to have a directory structure like this:

    app/
      app.html
      menu/
        menu.html
        menu.css

Then in `app.html` you include the menu:

    <include src = "menu/menu.html" />
    
And in `menu.html` you include `menu.css` that is relative to the `menu/` directory:

    <link href = "menu.css" />
    
This feature allows you to focus on one piece of your application, without worrying about the directory structure outside.

> Note: If you include a directory, `index.html` will be the default file it loads