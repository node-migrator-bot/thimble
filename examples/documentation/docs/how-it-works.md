## How it works ##

Thimble's architecture is heavily influenced by [connect](http://senchalabs.github.com/connect/). Connect's layering system is fantastic for providing modular middleware for the server. Thimble borrows this concept to provide an extensible HTML transformer for page requests.

The following is an example of thimble during the development cycle:

![diagram](/images/how-it-works.png)

In this diagram our requested page passes through thimble's plugins that transform its source before reaching you, the developer. These plugins do things like include other files, embed templates, dim distracting elements, and expose functions and objects from the server to the frontend.