window.Spec ||= {}

window.Spec.SeaweedDSL =
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
      fail:     -> Spec.fail.apply Spec, arguments
      title:    title
      ul:       ul
      before:   []
    }
    definition()
    Spec.testStack.pop()

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
    exp = new Spec.DelayedExpectation(message)
    Spec.currentTest().expectations.push exp
    exp
  
  # Syntactic sugar to create a before method that prepares a variable
  #
  # Example:
  #     given 'dog', -> new Dog()
  given: (name, definition) ->
    throw 'Definition for given must be a function' unless definition.call

    before ->
      @[name] = definition.call this
  
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
      definition.call this
  
  # Runs a test against @subject
  # 
  # Example
  #     subject -> new Employee()
  #     it -> should beAnInstanceOf(Employee)
  should: (matcher) ->
    expect(Spec.currentTest().env.subject).to matcher

  # Runs a negative test against @subject
  # 
  # Example
  #     subject -> new Employee()
  #     it -> shouldNot be(null)
  shouldNot: (matcher) ->
    expect(Spec.currentTest().env.subject).notTo matcher

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

window.Spec.SeaweedDSL.context = window.Spec.SeaweedDSL.describe