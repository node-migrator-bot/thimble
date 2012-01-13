## Documentation ##

Thimble's API is based off of [express](http://expressjs.com/) and is intentionally minimal. 

### Creating a thimble instance ###

To create an instance of thimble on your server, simply run invoke the thimble function, passing in a set of options.

    var thimble = require('thimble'), 
        thim = thimble(options);

The only option that is required is `root`. Here's an example:

    var thim = thimble({
      root : "./views"
    });
  
The `root` is where all your client-side views will live. If you use the `flatten` plugin, your assets should be in this directory as well.

Additional `options` may include:
  
  * `root` : Required. Directory containing your views.
  * `env` : The current environment. Defaults to `development`.
  * `template` : The variable templates will be saved under. Defaults to `JST`.
  * `namespace` : The namespace used on the client-side. Defaults to `window`.

> Note: You can always set these options later in the application using `thimble.set(option, value)`.

### Adding plugins ###

Once you have created an instance, you'll want to add plugins. Currently, thimble does not include any plugins by default, so you'll want to explicitly add them.

This is how you add a plugin:

    thim.use(thimble.flatten());
    
Now when you make requests to views, its source will pass through the `flatten` plugin.

Now you'll probably want to set up different plugins for different environments. For this, you'll need `thim.configure`. Here's an example:
    
    thim.configure(function() {
      thim.use(thimble.layout());
      thim.use(thimble.flatten());
      thim.use(thimble.embed());
    });
    
    thim.configure('development', function() {
      thim.use(thimble.focus('.menu'));
    });
    
    thim.configure('staging', function() {
      thim.use(thimble.bundle());
    });

When you do not pass an environment to the configuration, the configuration will run in all environments.

> Important: When adding multiple plugins, __order matters__. Differing order may yield different results. For example, placing `embed` before `flatten` in the configuration will embed templates in the index source, but not any of the included files.

### Starting Thimble ###

When all your configuration is set up, you can simply `start` thimble:

    thim.start(app);
    
In this example `app` is an express server. This call will configure the express to support thimble by loading the middleware into the server stack and monkey-patching `res.render` to provide a transparent interface.

> Note: Thimble may move certain express middleware layers (like `static`) to ensure a proper runtime.
