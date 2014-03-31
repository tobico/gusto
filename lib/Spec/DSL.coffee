window.Spec ||= {}

window.Spec.DSL = DSL =
  # Prepares a sub-test of the current test case
  describe: (title, definition) ->
    @__spec_definingSuite.add new Spec.Suite(title, definition)

  # Adds a setup step to the current test case
  before: (action) ->
    @__spec_definingSuite.filter null, action

  # Sets up a method stub for an object
  allow: (object) ->
    toReceive: (method) ->
      Spec.MethodStub.stub(object, method)

  # Sets up an expected result for this test
  expect: (object) ->
    # Specifies that the object should receive a positive response from a
    # matcher function
    to: (matcher) ->
      match = matcher(object)
      unless match.result
        error = new Spec.ExpectationError("expected to #{match.text()}")
        error.htmlMessage = match.html() if match.html
        throw error

    # Specifies that the object should receive a negative response
    notTo: (matcher) ->
      match = matcher(object)
      if match.result
        error = new Spec.ExpectationError("expected not to #{match.text()}")
        error.htmlMessage = match.html() if match.html
        throw error

    # Sets up a stub on the given method, with a delayed expectation that this
    # stub method be called
    toReceive: (method) ->
      Spec.MethodStub.stub(object, method).expect()

    # Sets up a stub on the given method, with a delayed expectation that this
    # stub method is never called
    notToReceive: (method) ->
      Spec.MethodStub.stub(object, method).expect().never()

  # Syntactic sugar to create a before method that prepares a variable
  #
  # Example:
  #     given 'dog', -> new Dog()
  given: (name, definition) ->
    @__spec_definingSuite.filter name, -> @[name] = definition.call this

  # Creates a specificaition
  it: (args...) ->
    test = switch args.length
      when 1
        if typeof args[0] == 'function'
          # Test with automatically generated title
          new Spec.Test(Spec.Util.descriptionize(args[0]), args[0])
        else
          # Pending test
          new Spec.Test(args[0], -> pending() )
      when 2
        # Test with manual title
        new Spec.Test(args...)
    @__spec_definingSuite.add test if test

  pending: (message=null) ->
    throw new Spec.PendingError(message)

  # Creates a specification that tests an attribute of subject
  #
  # Example:
  #     subject -> new Employee('Fred')
  #     its 'name', -> should equal('Fred')
  its: (attribute, definition) ->
    root = this
    it "#{attribute} #{Spec.Util.descriptionize definition}", ->
      root.__spec_subject = @subject = Spec.Util.dereference @subject[attribute]
      definition.call this

  # Runs a test against @subject
  #
  # Example
  #     subject -> new Employee()
  #     it -> should beAnInstanceOf(Employee)
  should: (matcher) ->
    expect(@__spec_subject).to matcher

  # Runs a negative test against @subject
  #
  # Example
  #     subject -> new Employee()
  #     it -> shouldNot be(null)
  shouldNot: (matcher) ->
    expect(@__spec_subject).notTo matcher

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
    new Spec.Mock(name, stubs)

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
    root = this
    definition = args.pop()
    name = args.pop()
    before ->
      root.__spec_subject = @subject = definition.call this
      @[name] = @subject if name

DSL.context = DSL.describe
DSL.specify = DSL.it
