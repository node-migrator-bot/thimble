## API ##

Thimble's API is based off of [express](http://expressjs.com/) and is intentionally minimal. 

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

### Adding plugins ###

Once you have created an instance, you'll want to add plugins. This is how you add a plugin:

    thimble.use(thimble.flatten());
    
Now when you make request, its source will pass through the `flatten` plugin. You can also use the `configure` function to add many plugins at once. For getting started, I'd recommend the following configuration:

    thimble.configure(function(use) {
      use(thimble.flatten());
      use(thimble.embed());
    });

You can also configure the stack for different environments:
    
    // Runs in all environments
    thim.configure('all', function() {
      thim.use(thimble.focus('.menu'));
    });
    
    // Runs when NODE_ENV=staging
    thim.configure('staging', function() {
      thim.use(thimble.bundle());
    });

When you do not pass an environment to the configuration, the configuration will run in the `development` environment.

> **Important**: When adding multiple plugins, **order matters**. Differing order may yield different results. For example, placing `embed` before `flatten` in the configuration will embed templates in the index source, but not any of the included files.

### Starting Thimble ###

When all your configuration is set up, you can simply `start` thimble:

    thimble.start(app);
    
In this example `app` is an express server. This call will configure the express to support thimble by loading the middleware into the server stack and monkey-patching `res.render` to provide a transparent interface.

> Note: Thimble may move certain express middleware layers (like `static`) to ensure a proper runtime.
 