### Package ###

Package will compile your application and move the source into the right spots.  Package requires the `public` and `build` options to be set and works best if the bundle plugin runs first.

Package moves assets out of the view and into the public directory. Since the bundle plugin inlined all of our css and javascript, package pulls them out and puts them in the `public` directory. Package also moves images out of the view and moves them to `public`. This includes images urls in the CSS. 

After all the assets are moved and tags re-written, the package plugin writes the view to the `build` directory.

The package plugin is part of the build script included in thimble and while developing, you probably will not need to use this plugin.
