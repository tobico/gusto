window.Spec ||= {}
window.Spec.WindowExtensions = {
  SpecObject: (object) ->
    $.extend this, object if object
    this
  
  # Tests if matched value === expected value
  be: (expected) ->
    (value) ->
      [value is expected, "to be #{Spec.inspect expected}, actual #{Spec.inspect value}"]

  # Tests if matched value is a boolean
  beABoolean: (value) ->
    [typeof value is 'boolean', "to have type &ldquo;boolean&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
  
  # Tests if matched value is a function
  beAFunction: (value) ->
    [typeof value is 'function', "to have type &ldquo;function&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]

  # Tests if matched value is a number
  beANumber: (value) ->
    [typeof value is 'number', "to have type &ldquo;number&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]

  # Tests if matched value is a string
  beAString: (value) ->
    [typeof value is 'string', "to have type &ldquo;string&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
  
  # Tests if matched value is an instance of class
  beAnInstanceOf: (klass) ->
    (value) ->
      [value instanceof klass, "to be an instance of &ldquo;#{klass}&rdquo;"]
  
  # Tests if matched value is an object
  beAnObject: (value) ->
    [typeof value is 'object', "to have type &ldquo;object&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
  
  # Tests if matched value is boolean false
  beFalse: (value) ->
    [String(value) == 'false', "to be false, got #{Spec.inspect value}"]

  # Adds a setup step to the current test case
  before: (action) ->
    test = Spec.testStack[Spec.testStack.length - 1]
    test.before.push action
  
  # Tests if matched value is boolean true
  beTrue: (value) ->
    [String(value) == 'true', "to be true, got #{Spec.inspect value}"]
  
  context: () ->
    describe.apply this, arguments

  # Prepares a sub-test of the current test case
  describe: (title, definition) ->
    parent = Spec.testStack[Spec.testStack.length - 1]

    ul = $('<ul></ul>')
    switch Spec.Format
      when 'ul'
        parent.ul.append($('<li>' + title + '</li>').append(ul))
      when 'terminal'
        $('.results').append(Spec.pad(title, parent.ul.depth) + "<br>")
        ul.depth = parent.ul.depth + 2

    Spec.testStack.push {
      title:    title
      ul:       ul
      before:   []
    }
    definition()
    Spec.testStack.pop()

  # Tests if matched value == expected value
  equal: (expected) ->
    (value) ->
      [String(value) == String(expected), "to match &ldquo;#{$.trim diffString(String(value), String(expected))}&rdquo;"]

  # Allows an assertion on a non-object value
  expect: (object) ->
    {
      to: (matcher) ->
        result = matcher(object)
        Spec.fail "expected #{result[1]}" unless result[0]
      notTo: (matcher) ->
        result = matcher(object)
        Spec.fail "expected not #{result[1]}" if result[0]
    }
  
  # Sets up an expectation
  expectation: (message) ->
    exp = {
      message:      message
      meet:         -> @met++
      met:          0
      desired:      1
      twice:        ->
        @desired = 2
        this
      exactly:      (times) ->
        @desired = times
        {times: this}
      timesString:  (times) ->
        switch times
          when 0
            'not at all'
          when 1
            'once'
          when 2
            'twice'
          else
            "#{times} times"
      check:        ->
        if @met != @desired
          Spec.fail "expected #{message} #{@timesString @desired}, actually received #{@timesString @met}"
    }
    Spec.expectations.push exp
    exp
  
  finishTest: ->
    for expectation in Spec.expectations
      expectation.check()

    reportTestResult(if Spec.passed then "passed" else "failed")

    delete Spec.expectations
    delete Spec.testTitle
    window.onerror = -> null

    Spec.env.sandbox.empty().remove()

  haveHtml: (expected) ->
    (value) ->
      div = $(document.createElement 'div')
      div.html expected
      normalized = div.html()
      actual = value.html()
      [actual == normalized, "to have html &ldquo;#{$.trim diffString(actual, normalized)}&rdquo;"]
  
  # All-purpose inclusion matcher
  include: (expected) ->
    if expected instanceof Array
      (value) ->
        match = true
        for test in expected
          match = false unless (value.indexOf && value.indexOf(test) >= 0) || value[test]?
        [match, "to include #{Spec.inspect expected}, actual #{Spec.inspect value}"]
    else if typeof expected == 'object'
      (value) ->
        missing = {}
        match = true
        for test of expected
          if expected.hasOwnProperty test
            unless value[test] isnt undefined && String(value[test]) == String(expected[test])
              match = false
              missing[test] = expected[test]
        [match, "to include #{Spec.inspect expected}, actual #{Spec.inspect value}, missing #{Spec.inspect missing}"]
    else
      include([expected])
      
  # Creates a specificaition
  it: (title, definition) ->
    test = Spec.testStack[Spec.testStack.length - 1]
    if definition?
      Spec.env = {sandbox: $('<div/>').appendTo document.body}
      for aTest in Spec.testStack
        for action in aTest.before
          action.call Spec.env

      Spec.expectations = []
      Spec.testTitle = title

      window.onerror = (message, url, line) ->
        Spec.fail message, "#{url.replace(document.location, '')}:#{line}"
        Spec.passed = false
        finishTest()

      Spec.passed = true
      definition.call Spec.env        
      finishTest()
    else
      reportTestResult "pending"

  reportTestResult: (status) ->
    test = Spec.testStack[Spec.testStack.length - 1]

    switch Spec.Format
      when 'ul'
        test.ul.append '<li class="' + status + '">' + Spec.testTitle + '</li>'
      when 'terminal'
        s = Spec.testTitle
        color = switch status
          when 'passed' then 32
          when 'failed' then 31
          when 'pending' then 33
        $('.results').append Spec.pad("&#x1b;[#{color}m#{s}&#x1b;[0m<br>", test.ul.depth)

    Spec.counts[status]++
    Spec.counts.total++

}