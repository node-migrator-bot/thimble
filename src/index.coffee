###
  index.coffee --- Matt Mueller
  
  The purpose of this provide an application interface for developing applications.
  It has two main functions : middleware(appDir), and render(file)
  
  middleware - will load all the required assets
  render - will parse the html comments
  
###


exports.render = require('./render').render

exports.middleware = require('./middleware').middleware
  
module.exports = exports
