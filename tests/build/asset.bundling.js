var path = require("path");
var fs = require("fs");
var assert = require("assert");

/*
  Directories
*/

var fixtures = path.resolve(__dirname + "/../fixtures");
var src = path.resolve(__dirname + "/../../src");
/*
  Libraries
*/

var vows = require("vows");
var coffeescript = require("coffee-script");
var jsdom = require("jsdom").jsdom;
var $ = require("jquery");

/*
  Definitions
*/

var suite = vows.describe("Asset Bundling");
var builder = require(src + "/builder.coffee");
var utils = require(src + "/utils.coffee");

/*
  Plugins
*/

var stylus = require("stylus");
var less = require("less");
var coffeescript = require("coffee-script");

/*
  Helper Functions
*/

var inString = function(str, sub) {
    return (str.indexOf(sub) >= 0);
}

/*
  Tests
*/


suite.addBatch({
    
  'When building the file...' : {
    topic : function() {
              
      builder.build(fixtures + "/initials/asset.bundling.html", {
        root : fixtures,
        build : fixtures + "/finals",
        public : fixtures + "/public/assetBundling",
      }, this.callback);
    },
    
    'There is no parsing error' : function(err, file) {
      assert.isNull(err);
    },
    
    'the applications source' : {
      topic : function(file) {
        var final = fs.readFileSync(file, "utf8");
        var document = jsdom(final);
        return document;
      },
                  
      // Javascript
      'JS: has only one <script> tag' : function(document) {
        var script = $('script', document).not(".thimble-test");

        // Only one script tag
        assert.equal(script.length, 1);

      },
      
      'JS: the source of the <script> tag is build.js' : function(document) {
        var script = $('script', document);

        // Only one script tag
        assert.equal(script.attr("src"), "build.js");
      },
      
      'JS: the <script> tag follows the <body>' : function(document) {
        var script = $(document.body).nextAll('script');
        assert.equal(script.length, 1);
        assert.equal(script.get(0).tagName, "SCRIPT");
      },
      
      // CSS
      
      'CSS: has only one <link> tag' : function(document) {
        var link = $('link', document);

        // Only one link tag
        assert.equal(link.length, 1);

      },
      
      'CSS: the source of the <link> tag is build.css' : function(document) {
        var link = $('link', document);

        // Only one script tag
        assert.equal(link.attr("href"), "build.css");
      },
      
      'CSS: the <link> tag is the last element in the <head>' : function(document) {
        var head = document.getElementsByTagName("head")[0];
        var link = head.lastChild.tagName;
        assert.equal(link, "LINK");
      }
    },
    
    "build.js" : {
      topic : function(file) {
        fs.readFile(fixtures + "/public/assetBundling/build.js", "utf8", this.callback);
      },
      
      'exists' : function(err, build) {
        assert.isNull(err);
      },
      
      'contains COFFEESCRIPT-rendered js' : function(err, build) {
        var asset = fs.readFileSync(fixtures + "/assets/hello.coffee", "utf8");
        var coffee = coffeescript.compile(asset);
        assert.isTrue(inString(build, coffee));
        
      },
      
      'contains the external JS files' : function(err, build) {
        var asset = fs.readFileSync(fixtures + "/assets/alert.js", "utf8");
        assert.isTrue(inString(build, asset));
      },
      
      'supports inline <script>\'s for' : {
        topic : function(build, file) {
          var final = fs.readFileSync(file, "utf8");
          // Pass back through JSDOM to get the document
          var document = jsdom(final);
          return document;
        },
        
        'COFFEE' : function(document) {
          var build = fs.readFileSync(fixtures + "/public/assetBundling/build.js", "utf8");
          
          $("script[type|='text/coffee']", document).each(function(i, elem) {
            var coffee = $(elem).html();
            assert.isTrue(inString(build, coffee));
          });
        }
        
      }
      
    },
    
    "build.css" : {
      topic : function(file) {
        fs.readFile(fixtures + "/public/assetBundling/build.css", "utf8", this.callback);
      },
      
      'exists' : function(err, build) {
        assert.isNull(err);
      },
      
      'contains STYLUS-rendered css' : function(err, build) {
        var asset = fs.readFileSync(fixtures + "/assets/stylish.styl", "utf8");
        stylus.render(asset, {}, function(err, css) {
          assert.isNull(err);
          assert.isTrue(inString(build, css));
        });
      },
      
      'contains LESS-rendered css' : function(err, build) {
        var asset = fs.readFileSync(fixtures + "/assets/lessy.less", "utf8");
        
        less.render(asset, function(err, css) {
          assert.isTrue(inString(build, css));
        });
      },
      
      'contains the external CSS files' : function(err, build) {
        var asset = fs.readFileSync(fixtures + "/assets/rofl.css", "utf8");
        assert.isTrue(inString(build, asset));
      },
      
      'supports inline <style>\'s for' : {
        topic : function(build, file) {
          var final = fs.readFileSync(file, "utf8");

          // Pass back through JSDOM to get the document
          var document = jsdom(final);
          return document;
        }, 
        
        'CSS' : function(document) {
          var build = fs.readFileSync(fixtures + "/public/assetBundling/build.css", "utf8");
          var css;
          $("style[type|='text/css']", document).each(function(i, elem) {
            css = $(elem).html();
            assert.isTrue(inString(build, css));
          });
        },
        
        'STYLUS' : function(document) {
          var build = fs.readFileSync(fixtures + "/public/assetBundling/build.css", "utf8");
          var styl;
          
          $("style[type|='text/styl']", document).each(function(i, elem) {
            styl = $(elem).html();
            styl = $.trim(styl);
            stylus.render(styl, {}, function(err, css) {
              assert.isTrue(inString(build, css));
            });
          });
          
        },
        
        'LESS' : function(document) {
          var build = fs.readFileSync(fixtures + "/public/assetBundling/build.css", "utf8");
          var less_style;
          
          $("style[type|='text/less']", document).each(function(i, elem) {
            less_style = $(elem).html();
            less_style = $.trim(less_style);
            less.render(less_style, function(err, css) {
              assert.isTrue(inString(build, css));
            });
          });
          
        },
      }
    }
 }   
}).export(module);