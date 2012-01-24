### Layout ###

Layout introduces the `yield` tag. Layouts work in the same way express provides layouts, by adding them through `res.render`. Here's an example:

    res.render('index/index', {
      name : "Matt",
      layout : "/layout.html"
    });
    
> Note: Currently, thimble squelches express's layout functionality, so layouts work with other bundles. Additionally, you will need to set layouts in `res.render` each time because there is not yet support for adding one default layout.