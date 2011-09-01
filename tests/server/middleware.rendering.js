var API, Browser, HOST, PORT, assert, macro, suite, tobi, vows;
HOST = 'localhost';
PORT = '80';
API = '/api/users/create';
vows = require("vows");
tobi = require("tobi");
assert = require("assert");
Browser = function() {
  return tobi.createBrowser(PORT, HOST);
};
macro = function(url) {
  return {
    "GET": {
      topic: function() {
        var browser;
        browser = newbie();
        return browser.get(url, this.callback);
      },
      "should fail": function(res, $) {
        return res.should.not.have.status(200);
      }
    },
    "Empty POST": {
      topic: function() {
        var browser;
        browser = newbie();
        return browser.post(url, this.callback);
      },
      "should fail": function(res, $) {
        return res.should.not.have.status(200);
      }
    }
  };
};
suite = vows.describe("User API test suite");
suite.addBatch(macro(URL));
suite.exports(module);