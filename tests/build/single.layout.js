var path = require("path");
var fs = require("fs");

var vows = require("vows");
var assert = require("assert");
var coffeescript = require("coffee-script");

/*
  Directories
*/

var fixtures = path.resolve(__dirname + "/../fixtures");
var src = path.resolve(__dirname + "/../../src");

/*
  Definitions
*/

var suite = vows.describe("Including Layouts");
var builder = require(src + "/builder.coffee");
var utils = require(src + "/utils.coffee");

/*
  Tests
*/

suite.addBatch({
  'When including a basic layout...' : {
    topic : function() {
      var self = this;
      builder.build(fixtures + "/initials/single.layout.html", {
        root : fixtures,
        build : fixtures + "/public/layouts",
        public : fixtures + "/public/layouts",
        layout : fixtures + "/layouts/single.layout.html"
      }, this.callback);
    },
   
   'build should compile' : function(err, file) {
     assert.isNull(err);
   },
   
   'should match final' : function(err, build) {
     var final = fs.readFileSync(build, "utf8");
     var compare = fs.readFileSync(fixtures + "/finals/single.layout.compare.html", "utf8");
     assert.strictEqual(compare, final);
     
   }
  }
    
}).export(module);