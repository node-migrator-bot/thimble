fs = require "fs"
path = require "path"

loadPlugins = (pluginDir) ->
  
  availablePlugins = fs.readdirSync pluginDir
  plugins = {}
  for plugin in availablePlugins
    fileArr = path.basename(plugin).split "."
    fileArr.pop()
    ext = fileArr.join "."
    plugins[ext] = pluginDir + "/" + plugin

  return plugins

plugin = (availablePlugins) ->
  plugins = availablePlugins
  p = (asset) ->
    ext = path.extname(asset).substring 1
    if !plugins[ext]
      false
    else
      return require plugins[ext]
      
  p.extensions = availablePlugins
  return p
  
module.exports = (pluginDir) ->
  pluginDir = path.join __dirname, pluginDir
  plugins = loadPlugins pluginDir
  return plugin(plugins)