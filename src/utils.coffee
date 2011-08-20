fs = require "fs"
_ = require "underscore"
path = require "path"

readFiles = exports.readFiles = (files, callback) ->
  _readFiles files, (err, files) ->
    callback null, _.toArray files
        
# Reads an array of files and returning them in order
_readFiles = (files, callback) ->
  if _.isString files
    files = [files]

  finished = countdown files.length
  output = toKeys files

  for file, val of output
    do (file) ->
      if file.indexOf("*") >= 0
        dir = path.dirname file
        filename = path.basename file
        filter = filename.replace "*", ".*"

        filterDir dir, filter, (err, files) ->
          throw err if err
          files = (dir + "/" + f for f in files)
          _readFiles files, (err, code) ->
            throw err if err
            output[file] = 
              file : file
              code : code
            callback null, output if finished()
      else
        fs.readFile file, "utf8", (err, code) ->
          throw err if err
          output[file] = 
            file : file
            code : code
          callback null, output if finished()
          
            
filterDir = exports.filterDir = (dir, filter, callback) ->
  regex = new RegExp filter
  files = []
  fs.readdir dir, (err, contents) ->
    return callback err if err
    for file in contents
      # Ignore stuff like .DS_STORE, .git, etc.
      if regex.test(file) and file[0] isnt "." 
        files.push file
      
    callback null, files

writeFiles = exports.writeFiles = (files, to, callback) ->
  finished = countdown _.size(files)

  for file, code of files
    fs.writeFiles to + file, code, "utf8", (err) ->
      throw err if err
      if finished()
        callback null

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
  fs.readFile file, (err, code) ->
    throw err if err
    filename = path.basename file

    fs.writeFile to + "/" + filename, code, (err) ->
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

iterator = exports.iterator = (arr, ptr = 0) ->
  {
    array : arr
    pointer : ptr
    length : arr.length
    next : ->
      @pointer++
      if @pointer is @length 
        @pointer = 0
        @array[0]
      else
        @array[@pointer]
    curr : ->
      @array[@pointer]
    reset : ->
      @pointer = 0
  }

hideTemplateTags = exports.hideTemplateTags = (str, hide = ["<%", "%>"], hideWith = ["<!--%%%", "%%%-->"]) ->
  str = str.replace hide[0], hideWith[0]
  str = str.replace hide[1], hideWith[1]
  return str

unhideTemplateTags = exports.unhideTemplateTags = (str, hide = ["<%", "%>"], hideWith = ["<!--%%%", "%%%-->"]) ->
  return hideTemplateTags str, hideWith, hide
  
module.exports = exports

# console.log fillArray 5, "hi"

# files = 
#   [
#     "./plugin"
#     "./builder"
#     "./middleware"
#   ]
# 
# readFiles files, (err, files) ->
#   console.log files
  
# copy files[0], "./../public/", (err) ->
#   throw err if err
#   console.log "Copied the files"