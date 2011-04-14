(function() {
  var __slice = Array.prototype.slice;
  window.Spec = {
    EnvironmentInitialized: false,
    Pad: function(string, times) {
      var i;
      for (i = 1; (1 <= times ? i <= times : i >= times); (1 <= times ? i += 1 : i -= 1)) {
        string = '&nbsp;' + string;
      }
      return string;
    },
    Escape: function(string) {
      return $('<div/>').text(String(string)).html();
    },
    describe: function(title, definition) {
      var ul;
      if (!this.EnvironmentInitialized) {
        this.initializeEnvironment();
      }
      ul = $('<ul></ul>');
      switch (this.Format) {
        case 'ul':
          $('.results').append($('<li>' + title + '</li>').append(ul));
          break;
        case 'terminal':
          $('.results').append("" + title + "<br>");
          ul.depth = 2;
      }
      this.testStack = [
        {
          title: title,
          ul: ul,
          before: []
        }
      ];
      return definition();
    },
    finalize: function() {
      var color, error, summary, ul, _i, _j, _len, _len2, _ref, _ref2, _results;
      summary = "" + this.counts.passed + " passed, " + this.counts.failed + " failed, " + this.counts.pending + " pending, " + this.counts.total + " total";
      switch (this.Format) {
        case 'ul':
          document.title = summary;
          if (this.errors.length) {
            $('<h3>Errors</h3>').appendTo(document.body);
            ul = $('<ul></ul>').addClass('errors').appendTo(document.body);
            _ref = this.errors;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              error = _ref[_i];
              _results.push(ul.append($('<li>').append($('<span>').html(error.message), ' - ', $('<span>').html(error.title))));
            }
            return _results;
          }
          break;
        case 'terminal':
          $('.results').append("<br>");
          _ref2 = this.errors;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            error = _ref2[_j];
            $('.results').append("&#x1b;[31m" + error.message + "&#x1b;[0m " + error.title + "<br>");
          }
          color = this.counts.failed > 0 ? 31 : this.counts.pending > 0 ? 33 : 32;
          return $('.results').append("&#x1b;[1m&#x1b;[" + color + "m" + summary + "&#x1b;[0m<br>");
      }
    },
    initializeEnvironment: function() {
      this.EnvironmentInitialized = true;
      this.errors = [];
      this.counts = {
        passed: 0,
        failed: 0,
        pending: 0,
        total: 0
      };
      this.Format = 'ul';
      if (location.hash === '#terminal') {
        this.Format = 'terminal';
      }
      switch (this.Format) {
        case 'ul':
          $('body').append('<ul class="results"></ul>');
          break;
        case 'terminal':
          $('body').append('<div class="results"></div>');
      }
      Object.prototype.should = function(matcher) {
        var result;
        if (typeof matcher === 'function') {
          result = matcher(this);
          if (!result[0]) {
            return Spec.fail("expected " + result[1]);
          }
        }
      };
      Object.prototype.shouldNot = function(matcher) {
        var result;
        if (typeof matcher === 'function') {
          result = matcher(this);
          if (result[0]) {
            return Spec.fail("expected not " + result[1]);
          }
        }
      };
      window.expectation = function(message) {
        var exp;
        exp = {
          message: message,
          meet: function() {
            return this.met++;
          },
          met: 0,
          desired: 1,
          twice: function() {
            this.desired = 2;
            return this;
          },
          exactly: function(times) {
            this.desired = times;
            return {
              times: this
            };
          },
          timesString: function(times) {
            switch (times) {
              case 0:
                return 'not at all';
              case 1:
                return 'once';
              case 2:
                return 'twice';
              default:
                return "" + times + " times";
            }
          },
          check: function() {
            if (this.met !== this.desired) {
              return Spec.fail("expected " + message + " " + (this.timesString(this.desired)) + ", actually received " + (this.timesString(this.met)));
            }
          }
        };
        Spec.expectations.push(exp);
        return exp;
      };
      Object.prototype.shouldReceive = function(name) {
        var object, passthrough, received;
        object = this;
        received = expectation("to receive &ldquo;" + name + "&rdquo;");
        passthrough = object[name];
        object[name] = function() {
          return received.meet();
        };
        received["with"] = function() {
          var expectArgs;
          expectArgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          object[name] = function() {
            var args, correct, i, _ref;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            received.meet();
            correct = true;
            if (expectArgs.length !== args.length) {
              correct = false;
            }
            if (correct) {
              for (i = 0, _ref = args.length; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
                if (String(expectArgs[i]) !== String(args[i])) {
                  correct = false;
                }
              }
            }
            if (!correct) {
              return Spec.fail("expected #" + name + " to be called with arguments &ldquo;" + (expectArgs.join(', ')) + "&rdquo;, actual arguments: &ldquo;" + (args.join(', ')) + "&rdquo;");
            }
          };
          return received;
        };
        received.andReturn = function(returnValue) {
          var fn;
          fn = object[name];
          object[name] = function() {
            fn.apply(this, arguments);
            return returnValue;
          };
          return received;
        };
        received.andPassthrough = function() {
          var fn;
          fn = object[name];
          object[name] = function() {
            fn.apply(this, arguments);
            return passthrough.apply(this, arguments);
          };
          return received;
        };
        return received;
      };
      Object.prototype.shouldNotReceive = function(name) {
        return this.shouldReceive(name).exactly(0).times;
      };
      window.expect = function(object) {
        return {
          to: function(matcher) {
            var result;
            result = matcher(object);
            if (!result[0]) {
              return Spec.fail("expected " + result[1]);
            }
          },
          notTo: function(matcher) {
            var result;
            result = matcher(object);
            if (result[0]) {
              return Spec.fail("expected not " + result[1]);
            }
          }
        };
      };
      window.beforeEach = function(action) {
        var test;
        test = Spec.testStack[Spec.testStack.length - 1];
        return test.before.push(action);
      };
      window.describe = window.context = function(title, definition) {
        var parent, ul;
        parent = Spec.testStack[Spec.testStack.length - 1];
        ul = $('<ul></ul>');
        switch (Spec.Format) {
          case 'ul':
            parent.ul.append($('<li>' + title + '</li>').append(ul));
            break;
          case 'terminal':
            $('.results').append(Spec.Pad(title, parent.ul.depth) + "<br>");
            ul.depth = parent.ul.depth + 2;
        }
        Spec.testStack.push({
          title: title,
          ul: ul,
          before: []
        });
        definition();
        return Spec.testStack.pop();
      };
      window.it = function(title, definition) {
        var aTest, action, color, env, expectation, li, s, status, test;
        test = Spec.testStack[Spec.testStack.length - 1];
        status = (function() {
          var _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
          if (definition != null) {
            env = {
              sandbox: $('<div/>').appendTo(document.body)
            };
            _ref = Spec.testStack;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              aTest = _ref[_i];
              _ref2 = aTest.before;
              for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
                action = _ref2[_j];
                action.call(env);
              }
            }
            Spec.expectations = [];
            Spec.testTitle = title;
            window.onerror = function(message) {
              return Spec.fail("Error: " + message);
            };
            Spec.passed = true;
            try {
              definition.call(env);
            } catch (e) {
              Spec.fail('Error: ' + e);
            }
            _ref3 = Spec.expectations;
            for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
              expectation = _ref3[_k];
              expectation.check();
            }
            delete Spec.expectations;
            delete Spec.testTitle;
            delete window.onerror;
            env.sandbox.empty().remove();
            if (Spec.passed) {
              return "passed";
            } else {
              return "failed";
            }
          } else {
            return "pending";
          }
        })();
        switch (Spec.Format) {
          case 'ul':
            li = $('<li>' + title + '</li>');
            li.addClass(status);
            test.ul.append(li);
            break;
          case 'terminal':
            s = title;
            color = (function() {
              switch (status) {
                case 'passed':
                  return 32;
                case 'failed':
                  return 31;
                case 'pending':
                  return 33;
              }
            })();
            $('.results').append(Spec.Pad("&#x1b;[" + color + "m" + s + "&#x1b;[0m<br>", test.ul.depth));
        }
        Spec.counts[status]++;
        return Spec.counts.total++;
      };
      window.beAFunction = function(value) {
        return [typeof value === 'function', "to have type &ldquo;function&rdquo;, actual &ldquo;" + (typeof value) + "&rdquo;"];
      };
      window.be = function(expected) {
        return function(value) {
          return [value === expected, "to be &ldquo;" + (Spec.Escape(expected)) + "&rdquo;, actual &ldquo;" + (Spec.Escape(value)) + "&rdquo;"];
        };
      };
      window.beTrue = function(value) {
        return [String(value) === 'true', "to be true, got &ldquo;" + (Spec.Escape(value)) + "&rdquo;"];
      };
      window.beFalse = function(value) {
        return [String(value) === 'false', "to be false, got &ldquo;" + (Spec.Escape(value)) + "&rdquo;"];
      };
      window.beAnInstanceOf = function(klass) {
        return function(value) {
          return [value instanceof klass, "to be an instance of &ldquo;" + klass + "&rdquo;"];
        };
      };
      return window.equal = function(expected) {
        return function(value) {
          return [String(value) === String(expected), "to equal &ldquo;" + (Spec.Escape(expected)) + "&rdquo;, actual &ldquo;" + (Spec.Escape(value)) + "&rdquo;"];
        };
      };
    },
    fail: function(message) {
      var item, titles, _i, _len, _ref;
      this.passed = false;
      this.error = message;
      titles = [];
      _ref = this.testStack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        titles.push(item.title);
      }
      titles.push(this.testTitle);
      return this.errors.push({
        title: titles.join(' '),
        message: message
      });
    },
    uninitializeEnvironment: function() {
      this.EnvironmentInitialized = false;
      delete Object.prototype.should;
      delete Object.prototype.shouldNot;
      delete window.expectation;
      delete Object.prototype.shouldReceive;
      delete Object.prototype.shouldNotReceive;
      delete window.expect;
      delete window.beforeEach;
      delete window.describe;
      delete window.context;
      delete window.it;
      delete window.beAFunction;
      delete window.be;
      delete window.beTrue;
      delete window.beFalse;
      delete window.beAnInstanceOf;
      return delete window.equal;
    }
  };
}).call(this);
