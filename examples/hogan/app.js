var express = require('express'),
    thimble = require('../..'),
    
    server = express.createServer();

var options = {
  root : __dirname
};

// Pass through the options
thimble(options);

thimble.configure(function(use) {
  use(thimble.embed());
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