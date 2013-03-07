window.Spec ||= {}

window.Spec.Matchers =
  # Tests if matched value === expected value
  be: (expected) ->
    (value) ->
      [value is expected, "to be #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}"]

  # Tests that value type matches specified class
  beA: (klass) ->
    switch klass
      when Boolean  then _haveType 'boolean'
      when Function then _haveType 'function'
      when Number   then _haveType 'number'
      when String   then _haveType 'string'
      when Object   then _haveType 'object'
      else _beAnInstanceOf klass

  # Tests if matched value == expected value
  equal: (expected) ->
    (value) ->
      [String(value) == String(expected), "“#{String value}” to equal “#{String expected}” – #{$.trim diffString(String(value), String(expected))}"]
  
  # All-purpose inclusion matcher
  include: (expected) ->
    if expected instanceof Array
      (value) ->
        match = true
        for test in expected
          match = false unless (value.indexOf && value.indexOf(test) >= 0) || value[test]?
        [match, "to include #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}"]
    else if typeof expected == 'object'
      (value) ->
        missing = {}
        match = true
        for test of expected
          if expected.hasOwnProperty test
            unless value[test] isnt undefined && String(value[test]) == String(expected[test])
              match = false
              missing[test] = expected[test]
        [match, "to include #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}, missing #{Spec.Util.inspect missing}"]
    else
      include([expected])
  
  # Tests if a function causes an error to be thrown when called
  throwError: (message) ->
    (fn) ->
      thrown = false
      try
        fn()
      catch e
        thrown = e.message
      finally
        if thrown
          return [thrown == message, "to throw an error with message “#{String thrown}”, actual message “#{String message}” – #{$.trim diffString(String(thrown), String(message))}"]
        else
          return [false, "to throw an error with message “#{message}”, no error thrown"]

  # Tests a value type using typeof
  _haveType: (type) ->
    (value) ->
      [typeof value is type, "to have type “#{type}”, actual “#{typeof value}”"]

  # Tests if matched value is an instance of class
  _beAnInstanceOf: (klass) ->
    (value) ->
      [value instanceof klass, "to be an instance of “#{klass}”"]

window.Spec.Matchers.beAn = window.Spec.Matchers.beA
