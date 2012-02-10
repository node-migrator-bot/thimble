var express = require('express'),
    thimble = require('thimble');
  
var app = express.createServer();

app.configure(function() {
  app.set('views', __dirname + '/views');
  app.use(express.methodOverride());
  app.use(express.bodyParser());
  app.use(express.favicon());
});

/*
  Configure thimble
*/
thimble.configure(function(use) {
  use(thimble.embed());
});

thimble.start(app);

app.get('/', function(req, res) {
  res.render('index.html', {
    layout: false
  });
});

app.listen(8080);