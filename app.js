var express = require('express'),
    thimble = require('thimble'),
    server = express.createServer();

server.configure(function() {
    server.use(express.favicon());
});

var options = {
  root : './client',
  build : './build',
  'public' : './public'
};

// Pass through the options
thimble(options);

thimble.configure(function(use) {
  use(thimble.flatten());
  use(thimble.bundle());
  use(thimble.package());
});

// Start thimble
thimble.start(server);

server.get('/', function(req, res) {
   res.render('index', {
       layout : 'layout.html'
   }); 
});

server.listen(8080);
console.log('Server listening on port 8080');