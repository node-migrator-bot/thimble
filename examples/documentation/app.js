var express = require('express'),
    thimble = require('../..'),
    
    server = express.createServer();

server.configure(function() {
    server.use(express.favicon());
});

// Create the thimble instance
var thim = thimble.create({
   root : '.'
});

thim.configure(function() {
   thim.use(thimble.flatten); 
});

// Start thimble
thim.start(server);

server.get('/', function(req, res) {
   res.render('index'); 
});

server.listen(8080);
console.log('Server listening on port 8080');