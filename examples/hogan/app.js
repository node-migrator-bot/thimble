var express = require('express'),
    thimble = require('../..'),
    
    server = express.createServer();

var options = {
  root : __dirname,
  build : "./build",
  public : "./public"
};

// Pass through the options
thimble(options);

thimble.configure(function(use) {
  use(thimble.embed());
  use(thimble.bundle());
  use(thimble.package());
});

// Start thimble
thimble.start(server);

server.get('/', function(req, res) {
   res.render('index.mu', {
     computer : 'server'
   }); 
});

server.listen(8080);
console.log('Server listening on port 8080');