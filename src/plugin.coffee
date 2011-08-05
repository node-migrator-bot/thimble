fs = require "fs"
path = require "path"

loadPlugins = (pluginDir) ->
  
  availablePlugins = fs.readdirSync pluginDir
  plugins = {}
  for plugin in availablePlugins
    fileArr = plugin.split "."
    fileArr.pop()
    ext = fileArr.join "."
    plugins[ext] = pluginDir + "/" + plugin

  return plugins

genericPlugin = 
  render : (content, file, output) ->
    output null, content

plugin = exports.plugin = (availablePlugins) ->
  plugins = availablePlugins

  return (asset) ->
    ext = path.extname(asset).substring 1
    
    if !plugins[ext]
      genericPlugin.type = ext
      return genericPlugin
    else
      return require plugins[ext]
    
module.exports = do ->
  plugins = loadPlugins "#{__dirname}/plugins"
  return plugin(plugins)