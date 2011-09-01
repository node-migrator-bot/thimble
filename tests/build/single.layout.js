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
        build : fixtures + "/public/layouts",
        public : fixtures + "/public/layouts",
        layout : fixtures + "/layouts/single.layout.html"
      }, function(err, file) {
        assert.isNull(err);
        compiled = require(file);
        self.callback.call(null, err, compiled({}));
      });
    },
   
   'build should compile' : function(err, file) {
     assert.isNull(err);
   },
   
   'should match final' : function(err, build) {
     var final = fs.readFileSync(fixtures + "/finals/single.layout.html", "utf8");
     assert.strictEqual(build, final);
     
   }
  }
    
}).export(module);