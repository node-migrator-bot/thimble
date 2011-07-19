lib = "#{__dirname}/.."

build = exports.build = (assets, public, callback) ->
  console.log "From embed.coffee: " + assets
  
  callback "Embed's source is undefined!"

module.exports = exports
