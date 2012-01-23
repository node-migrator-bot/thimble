// Add current directory node_modules to require paths
require.paths.unshift(join(process.cwd(), 'node_modules'));

// Load thimble
module.exports = require(__dirname + '/lib/thimble.js');