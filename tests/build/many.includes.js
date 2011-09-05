var path = require("path");
var fs = require("fs");

var vows = require("vows");
var assert = require("assert");
var coffeescript = require("coffee-script");
var jsdom = require("jsdom").jsdom;

/*
  Directories
*/

var fixtures = path.resolve(__dirname + "/../fixtures");
var src = path.resolve(__dirname + "/../../src");

/*
  Definitions
*/

var suite = vows.describe("Multiple Includes");
var builder = require(src + "/builder.coffee");
var utils = require(src + "/utils.coffee");

/*
  Tests
*/


suite.addBatch({
  'When including a multiple subviews...' : {
    topic : function() {
      builder.build(fixtures + "/initials/many.includes.html", {
        root : fixtures,
        build : fixtures + "/finals",
        public : fixtures + "/public/assetBundling",
      }, this.callback);
    },

    "there is no error parsing the file" : function(err, file) {
      assert.isNull(err);
    },
    
    "the includes are in the final" : function(err, file) {
      assert.isNull(err);
      var apple = fs.readFileSync(fixtures + '/includes/apple.html', 'utf8');
      var carrot = fs.readFileSync(fixtures + '/includes/carrot.html', 'utf8');
      var grape = fs.readFileSync(fixtures + '/includes/grape.html', 'utf8');
      var pear = fs.readFileSync(fixtures + '/includes/pear.html', 'utf8');

      var final = fs.readFileSync(fixtures + "/finals/many.includes.html", "utf8");

      // Since there are inconsistencies with jsdom, I shouldn't be testing
      // for them here. Run each through jsdom and then compare.
      apple = jsdom(apple).innerHTML;
      carrot = jsdom(carrot).innerHTML;
      grape = jsdom(grape).innerHTML;
      pear = jsdom(pear).innerHTML;

      var inString = function(str, sub) {
          return (str.indexOf(sub) >= 0);
      }

      assert.isTrue(inString(final, apple));
      assert.isTrue(inString(final, carrot));
      assert.isTrue(inString(final, grape));
      assert.isTrue(inString(final, pear));      
    }

  }
  
}).export(module);
