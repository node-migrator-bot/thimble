### Build your application ###

When you are ready to build your application, thimble provides a build script. Thimble will bundle and package up your application to prepare it for production. You run the build script from the command line. You can specify the following `options`:
  
* `source` : Entry-point in your application. **Required**. 
* `root` : Main client-side directory. **Required**. 
* `public` : Where your assets will go when built. **Required**. 
* `build` : Where your views will go when built. **Required**. 
* `layout` : The layout template that will wrap your application.
* `template` : The variable templates will be saved under. Defaults to `JST`.
* `namespace` : The namespace used on the client-side. Defaults to `window`.
  
Running the thimble build script might like something like this:

    $ thimble --build build/ --public public/ --root client/ --layout client/layout.html client/index.html

Providing all these options is kind of a pain, so you can create a `thimble.opts` in your main directory and specify these options in there:

    --root client/
    --build build/
    --public public/
    --layout client/layout.html
    --source client/index.html
    
Then in the command line, it's simply:

    $ thimble
    Thimble successfully built your application

To run your application in the production environment, specify `NODE_ENV=production` when launching your node application:

    $ NODE_ENV=production node app.js