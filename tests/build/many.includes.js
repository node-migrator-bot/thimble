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
var parser = require(src + "/parser.coffee");
var utils = require(src + "/utils.coffee");

/*
  Tests
*/


suite.addBatch({
  'When including a multiple subviews...' : {
    topic : function() {
      parser.parse(fixtures + "/initials/many.includes.html", {}, this.callback);
    },

    "there is no error parsing the file" : function(err, code) {
      assert.isNull(err);
    },
    
    "the output is a string" : function(err, code) {
      assert.isString(code);
    },
    
    "the includes are in the final" : function(err, parsed) {
      assert.isNull(err);
      var apple = fs.readFileSync(fixtures + '/includes/apple.html', 'utf8');
      var carrot = fs.readFileSync(fixtures + '/includes/carrot.html', 'utf8');
      var grape = fs.readFileSync(fixtures + '/includes/grape.html', 'utf8');
      var pear = fs.readFileSync(fixtures + '/includes/pear.html', 'utf8');

      // Since there are inconsistencies with jsdom, I shouldn't be testing
      // for them here. Run each through jsdom and then compare.
      apple = jsdom(apple).innerHTML;
      carrot = jsdom(carrot).innerHTML;
      grape = jsdom(grape).innerHTML;
      pear = jsdom(pear).innerHTML;

      var inString = function(str, sub) {
          return (str.indexOf(sub) >= 0);
      }

      assert.isTrue(inString(parsed, apple));
      assert.isTrue(inString(parsed, carrot));
      assert.isTrue(inString(parsed, grape));
      assert.isTrue(inString(parsed, pear));      
    },
    
    /*
        JSDOM/htmlparser not there yet.
    */
    // "the final matches the initial" : function(err, parsed) {
    //     var final = fs.readFileSync(fixtures + '/finals/many.includes.html', 'utf8');
    //     final = jsdom(final).innerHTML;
    //     parsed = jsdom(parsed).innerHTML;
    //     
    //     assert.strictEqual(parsed, final);
    // }  
  }
  
}).export(module);
