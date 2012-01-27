### Starting Thimble ###

When all your configuration is set up, you can simply `start` thimble:

    thimble.start(app);
    
In this example `app` is an express server. This call will configure express to support thimble by loading middleware into the server stack and monkey-patching `res.render` to provide a transparent interface.

> Note: Thimble may modify certain express middleware layers (like `static`) to ensure a proper runtime.