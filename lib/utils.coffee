fs = require "fs"
_ = require "underscore"

# Reads an array of files and returning them in order
readFiles = exports.readFiles = (files, callback) ->
  filesLeft = files.length
  files = toKeys files
  
  for file, val of files
    do (file) ->
      fs.readFile file, "utf8", (err, code) ->
        throw err if err
        files[file] = code

        filesLeft--
        if filesLeft is 0
          callback null, files

writeFiles = exports.writeFiles = (files, to, callback) ->
  filesLeft = _.size files
  
  for file, code of files
    fs.writeFiles to + file, code, "utf8", (err) ->
      throw err if err
      filesLeft--
      callback null if filesLeft is 0

# Turns an array into an hashtable adding the array values to value
toValues = exports.toValues = (array, prefix = "") ->
  hash = {}
  for item, i in array
    hash[prefix + i] = item
  
  return hash

# Turns an array into an hashtable adding the array values to keys
toKeys = exports.toKeys = (array, prefix = "") ->
  hash = {}
  
  for item, i in array
    hash[prefix + item] = ""
    
  return hash

# Copies a file from one place to another
copy = exports.copy = (file, to, callback) ->
  fs.readFile file, "utf8", (err, code) ->
    throw err if err
    fs.writeFile to + file, code, "utf8", (err) ->
      throw err if err
      callback null

# Pretty elegant counter
countdown = exports.countdown = (length) ->
  left = length
  return ->
    left--
    if left <= 0
      return true
    else
      return false

# Fill an array with a given value
fillArray = exports.fillArray = (length, value) ->
  value for num in [0...length]

mkdir = exports.mkdir = (path) ->
  fs.mkdir path, 0777, (err)

module.exports = exports

# console.log fillArray 5, "hi"

# files = 
#   [
#     "./plugin.coffee"
#     "./builder.coffee"
#     "./middleware.coffee"
#   ]
# 
# readFiles files, (err, files) ->
#   console.log files
  
# copy files[0], "./../public/", (err) ->
#   throw err if err
#   console.log "Copied the files"