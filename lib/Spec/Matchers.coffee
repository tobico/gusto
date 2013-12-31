window.Spec ||= {}

window.Spec.Matchers =
  # Tests if matched value === expected value
  be: (expected) ->
    (value) ->
      result:       value is expected
      description:  -> "be #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}"

  # Tests that value type matches specified class
  beA: (klass) ->
    switch klass
      when Boolean  then _haveType 'boolean', klass
      when Function then _haveType 'function', klass
      when Number   then _haveType 'number', klass
      when String   then _haveType 'string', klass
      when Object   then _haveType 'object', klass
      else _beAnInstanceOf klass

  # Tests if matched value == expected value
  equal: (expected) ->
    (value) ->
      result:       String(value) == String(expected)
      description:  -> "equal “#{String expected}”, actual “#{String value}” – #{$.trim diffString(String(value), String(expected))}"

  # All-purpose inclusion matcher
  include: (expected) ->
    if expected instanceof Array
      (value) ->
        match = true
        for test in expected
          match = false unless (value.indexOf && value.indexOf(test) >= 0) || value[test]?
        result:       match
        description:  -> "include #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}"
    else if typeof expected == 'object'
      (value) ->
        missing = {}
        match = true
        for test of expected
          if expected.hasOwnProperty test
            unless value[test] isnt undefined && String(value[test]) == String(expected[test])
              match = false
              missing[test] = expected[test]
        result:       match
        description:  -> "include #{Spec.Util.inspect expected}, actual #{Spec.Util.inspect value}, missing #{Spec.Util.inspect missing}"
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
      if thrown
        result:      thrown == message
        description: -> "throw an error with message “#{String thrown}”, actual message “#{String message}” – #{$.trim diffString(String(thrown), String(message))}"
      else
        result:      false
        description: -> "throw an error with message “#{message}”, no error thrown"

  # Tests a value type using typeof, falling back to instanceof if type is an object
  _haveType: (type, klass) ->
    (value) =>
      if typeof value is 'object'
        @_beAnInstanceOf(klass)(value)
      else
        result:       typeof value is type
        description:  -> "to have type “#{type}”, actual “#{typeof value}”"

  # Tests if matched value is an instance of class
  _beAnInstanceOf: (klass) ->
    (value) ->
      result:      value instanceof klass
      description: -> "#{value} to be an instance of “#{klass.name || klass}”, actually “#{Spec.Util.inspectClass value}"

window.Spec.Matchers.beAn = window.Spec.Matchers.beA
