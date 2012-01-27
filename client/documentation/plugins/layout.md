### Layout ###

Layout introduces the `yield` tag. Layouts work in the same as express - by adding them through `res.render`. Here's an example:

    res.render('index/index', {
      name : "Matt",
      layout : "/layout.html"
    });

The layout plugin is added automatically when you specify the `layout` property.

> **Note:** Currently, thimble squelches express's layout functionality, so layouts work with other bundles. Additionally, you will need to set layouts in `res.render` each time because there is not yet support for adding one default layout.