### Using plugins ###

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