## How it works ##

Thimble's architecture is influenced by [connect](http://senchalabs.github.com/connect/). Connect's layering system is fantastic for providing modular middleware on the server. Thimble borrows this concept to provide modular HTML transformers for page requests.

During development, thimble inserts two middleware layers. The first layer manipulates your page request, running plugins like flatten and embed. The second layer catches requested assets, offering seamless integration with the latest languages and preprocessors like coffeescript and stylus. 

The following is an example of thimble's first layer during the development cycle:

![diagram](/images/how-it-works.png)

In this diagram the requested page passes through thimble's plugins to transform its source before reaching you, the developer. These plugins do things like include other files, embed templates, dim distracting elements, and expose functions and objects from the server to the frontend.

For production, thimble provides a build tool that compiles and bundles your assets into a single package that you can dish out to your servers.
