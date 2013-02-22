window.Spec ||= {}

window.Spec.WindowExtensions =
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

  # Tests if matched value is an object
  beAnObject: (value) ->
    [typeof value is 'object', "to have type &ldquo;object&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
  
  beA: (klass) ->
    beAnInstanceOf klass

  # Tests if matched value is an instance of class
  beAnInstanceOf: (klass) ->
    (value) ->
      [value instanceof klass, "to be an instance of &ldquo;#{klass}&rdquo;"]

  # Tests if matched value is an array
  beAnArray: (value) ->
    beAnInstanceOf(Array)(value)
  
  # Tests if given attribute is true
  beAttribute: (attribute) ->
    (value) ->
      result = value[attribute]
      result = result.call value if typeof result is 'function'
      [!!result, "to be #{attribute}"]
  
  # Tests if matched value is boolean false
  beFalse: (value) ->
    [String(value) == 'false', "to be false, got #{Spec.inspect value}"]

  # Adds a setup step to the current test case
  before: (action) ->
    Spec.currentTest().before.push action
  
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
      [String(value) == String(expected), "&ldquo;#{String value}&rdquo; to equal &ldquo;#{String expected}&rdquo; &mdash; #{$.trim diffString(String(value), String(expected))}"]

  # Allows an assertion on a non-object value
  expect: (object) ->
    {
      to: (matcher) ->
        result = Spec.findMatcher(matcher)(object)
        Spec.fail "expected #{result[1]}" unless result[0]
      notTo: (matcher) ->
        result = Spec.findMatcher(matcher)(object)
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
          Spec.fail "expected to #{message} #{@timesString @desired}, actually happened #{@timesString @met}"
    }
    Spec.currentTest().expectations.push exp
    exp
  
  # Syntactic sugar to create a before method that prepares a variable
  #
  # Example:
  #     given 'dog', -> new Dog()
  given: (name, definition) ->
    before ->
      @[name] = definition.call this
  
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
  it: (title=null, definition) ->
    Spec.test title, definition
  
  # Creates a specification that tests an attribute of subject
  #
  # Example:
  #     subject -> new Employee('Fred')
  #     its 'name', -> should equal('Fred')
  its: (attribute, definition) ->
    it "#{attribute} #{Spec.descriptionize definition}", ->
      value = @subject[attribute]
      value = value.call @subject if typeof value is 'function'
      @subject = value
      definition.call Spec.env
  
  # Runs a test against @subject
  # 
  # Example
  #     subject -> new Employee()
  #     it -> should beAnInstanceOf(Employee)
  should: (matcher) ->
    expect(Spec.env.subject).to matcher

  # Runs a negative test against @subject
  # 
  # Example
  #     subject -> new Employee()
  #     it -> shouldNot be(null)
  shouldNot: (matcher) ->
    expect(Spec.env.subject).notTo matcher

  # Creates a new mock object
  # 
  # Pass in a hash of method stubs to add to your mock.
  #
  # `mock(boots: 'cats')` gives an object that has the method:
  # `boots: -> 'cats'`
  #
  # Optionally, you can pass a name to identify this mock as the
  # first parameter.
  #
  mock: (args...) ->
    name = args.shift() if typeof args[0] is 'string'
    stubs = args.pop() || {}
    new Spec.MockObject(name, stubs)
  
  # Defines the subject of your test.
  #
  # Pass in a definition method which returns an object to be your
  # test subject. This will be assigined to the instance variable
  # @subject before your test runs. This subject will be used for
  # any `should` or `shouldNot` tests you specify using the global
  # `should` and `shouldNot` methods.
  #
  #     subject -> new Client()
  #     
  #     it { should beA Client }
  #
  # Optionally, you can specify a name for your subject as the
  # first parameter. This lets you call the subject by its name,
  # making your tests more readable.
  #
  #     subject 'foo', -> ...
  #     
  #     it 'gets prepared' ->
  #       @foo.prepare
  #       should 'bePrepared'
  #
  subject: (args...) ->
    definition = args.pop()
    name = args.pop()
    before ->
      @subject = definition.call this
      @[name] = @subject if name
