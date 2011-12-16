handlebars = require "handlebars"
fs = require "fs"

bars = fs.readFileSync "./files/handle.hb", 'utf8'

template = handlebars.precompile bars

console.log template.toString()