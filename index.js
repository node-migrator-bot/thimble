// Use source if we have coffeescript otherwise use lib
var dir = 'lib';
try {
    require('./node_modules/coffee-script');
    dir = 'src';
} catch (e) { }

module.exports = require(__dirname + '/' + dir + '/thimble.coffee');
