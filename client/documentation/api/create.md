### Creating a thimble instance ###

By default when you require thimble, it will automatically create an instance:

    var thimble = require('thimble');

If you'd like to create another instance of thimble you can call the command `create`:
    
    var friend = thimble.create([options]);

You can add options by calling the thimble function. Here's an example:

    thimble({
      root : './views',
      build : './build',
      public : './public'
    });

To get started you'll only need to specify the `root` property. However, if you're looking to eventually deploy application using thimble, it's a good idea to add the `public` and `build` directories as well.

Additional `options` you can add include:
  
  * `root` : Main client-side directory. Required for `development`.
  * `public` : Where your assets will go when built. Required for `production`.
  * `build` : Where your views will go when built. Required for `production`.
  * `env` : The current environment. Defaults to `development`.
  * `template` : The variable templates will be saved under. Defaults to `JST`.
  * `namespace` : The namespace used on the client-side. Defaults to `window`.

> Note: You can always set these options later in the application using `thimble.set(option, value)`.
