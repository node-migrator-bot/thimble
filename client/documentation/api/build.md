### Build your application ###

When you are ready to build your application, thimble provides a build script. Thimble will bundle and package up your application getting it ready for production. You run the build script from the command line. You'll need to specify the following `options`:
  
* `source` : **Required**. Entry-point in your application.
* `root` : **Required**. Main client-side directory.
* `public` : **Required**. Where your assets will go when built.
* `build` : **Required**. your views will go when built.
* `layout` : The layout template that will wrap your application.
* `template` : The variable templates will be saved under. Defaults to `JST`.
* `namespace` : The namespace used on the client-side. Defaults to `window`.
  
    