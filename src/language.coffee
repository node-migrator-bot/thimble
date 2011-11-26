
###
  The purpose of this file is to provide an consistent interface to
  the available languages
###

fs = require "fs"
path = require "path"

loadPlugins = (languageDir) ->
  
  availablePlugins = fs.readdirSync languageDir
  languages = {}
  for language in availablePlugins
    fileArr = path.basename(language).split "."
    fileArr.pop()
    ext = fileArr.join "."
    languages[ext] = languageDir + "/" + language

  return languages

language = (availablePlugins) ->
  languages = availablePlugins
  p = (asset) ->
    ext = path.extname(asset).substring 1
    if !languages[ext]
      false
    else
      return require languages[ext]
      
  p.extensions = availablePlugins
  return p
  
module.exports = (languageDir) ->
  languageDir = path.join __dirname, languageDir
  languages = loadPlugins languageDir
  return language(languages)