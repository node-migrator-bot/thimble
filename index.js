// Use source if we have coffeescript otherwise use lib
var dir = 'lib';
try {
    require('coffee-script');
    dir = 'src';
} catch (e) { }

module.exports = require(__dirname + '/' + dir + '/cheerio.coffee');
