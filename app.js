var express = require('express'),
    thimble = require('thimble');
  
var app = express.createServer();

app.configure(function() {
  app.use(express.methodOverride());
  app.use(express.bodyParser());
  app.use(express['static']('./public'));
  app.use(express.favicon());
});

thimble({
  root : './client'
});

thimble.configure(function(use) {
  use(thimble.flatten());
});

thimble.start(app);

app.get('/', function(req, res) {

  res.render('index.html');

});

app.listen(8080);
console.log("Server started on port 8080");