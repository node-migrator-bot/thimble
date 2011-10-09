// Use source if we have coffeescript otherwise use lib
try {
    require('coffee-script');
    module.exports = require(__dirname + "/src/server.coffee");
} catch (e) {
    module.exports = require(__dirname + "/lib/server.js");
}