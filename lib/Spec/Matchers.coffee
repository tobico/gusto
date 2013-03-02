window.Spec ||= {}

window.Spec.Matchers =
  # Tests if matched value === expected value
  be: (expected) ->
    (value) ->
      [value is expected, "to be #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}"]

  # Tests that value type matches specified class
  beA: (klass) ->
    switch klass
      when Boolean  then haveType 'boolean'
      when Function then haveType 'function'
      when Number   then haveType 'number'
      when String   then haveType 'string'
      when Object   then haveType 'object'
      else beAnInstanceOf klass

  # Tests a value type using typeof
  haveType: (type) ->
    (value) ->
      [typeof value is type, "to have type &ldquo;#{type}&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]

  # Tests if matched value is an instance of class
  beAnInstanceOf: (klass) ->
    (value) ->
      [value instanceof klass, "to be an instance of &ldquo;#{klass}&rdquo;"]
  
  # Tests if given attribute is true
  beAttribute: (attribute) ->
    (value) ->
      result = value[attribute]
      result = result.call value if typeof result is 'function'
      [!!result, "to be #{attribute}"]
  
  # Tests if matched value is boolean false
  beFalse: (value) ->
    [String(value) == 'false', "to be false, got #{Spec.Util.inspect value}"]
  
  # Tests if matched value is boolean true
  beTrue: (value) ->
    [String(value) == 'true', "to be true, got #{Spec.Util.inspect value}"]
  
  # Tests if matched value == expected value
  equal: (expected) ->
    (value) ->
      [String(value) == String(expected), "&ldquo;#{String value}&rdquo; to equal &ldquo;#{String expected}&rdquo; &mdash; #{$.trim diffString(String(value), String(expected))}"]
  
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

window.Spec.Matchers.beAn = window.Spec.Matchers.beA
