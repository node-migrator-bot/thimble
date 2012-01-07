### Layout ###

Layout introduces the `yield` tag. Layouts work in the same way express provides layouts, by adding them through `res.render`. Here's an example:

    res.render('index/index', {
      name : "Matt",
      layout : "/layout.html"
    });
    
> Note: Currently, there is no support for adding one default layout.