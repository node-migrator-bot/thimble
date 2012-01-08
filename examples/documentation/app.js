var express = require('express'),
    thimble = require('../..'),
    
    server = express.createServer();

server.configure(function() {
    server.use(express.favicon());
});

// Create the thimble instance
var thim = thimble.create({
   root : '.',
   build : './build',
   public : './public'
});

thim.configure(function() {
   thim.use(thimble.flatten);
   thim.use(thimble.bundle());
   thim.use(thimble.package());
});

// Start thimble
thim.start(server);

server.get('/', function(req, res) {
   res.render('index/index', {
       layout : 'layout.html'
   }); 
});

server.listen(8080);
console.log('Server listening on port 8080');