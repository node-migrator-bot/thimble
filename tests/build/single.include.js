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

var suite = vows.describe("Single Include");
var parser = require(src + "/parser.coffee");
var utils = require(src + "/utils.coffee");

/*
  Tests
*/


suite.addBatch({
  'When including a single subview...' : {
    topic : function() {
      parser.parse(fixtures + "/initials/single.include.html", {}, this.callback);
    },

    "there is no error parsing the file" : function(err, code) {
      assert.isNull(err);
    },
    
    "the output is a string" : function(err, code) {
      assert.isString(code);
    },
    
    "the initial matches the final" : function(err, initial) {
      assert.isNull(err);
      var final = fs.readFileSync(fixtures + '/finals/single.include.html', "utf8");
      assert.strictEqual(initial, final);
    }  
  }
  
}).export(module);
