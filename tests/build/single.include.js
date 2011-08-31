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

var suite = vows.describe("Including subviews");
var parser = require(src + "/parser.coffee");
var utils = require(src + "/utils.coffee");

/*
  Tests
*/

var loadFiles = function() {
  var args = Array.prototype.slice.call(arguments);
  
}

suite.addBatch({
  'When including a subview:' : {
    topic : function() {
      parser.parse(fixtures + "/basic/initial.html", {}, this.callback);
    },

    "there is no error" : function(err, code) {
      assert.isNull(err);
    },
    
    "the output is a string" : function(err, code) {
      assert.isString(code);
    },
    
    "the string is in the view" : function(err, code) {
      assert.isNull(err);
      var snippet = fs.readFileSync(fixtures + '/basic/snippet.html', "utf8");
      var index = code.indexOf(snippet);
      assert.isTrue(index >= 0);
    },
    
    "the initial matches the final" : function(err, initial) {
      assert.isNull(err);
      var final = fs.readFileSync(fixtures + '/basic/final.html', "utf8");
      assert.strictEqual(initial, final);
      
    }  
  },
  
  'When including tons of subviews' : {
    
  }
  
}).export(module);
