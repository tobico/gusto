window.Spec ||= {}

window.Spec.SeaweedDSL =
  # Prepares a sub-test of the current test case
  describe: (title, definition) ->
    parent = @suite
    @suite = new Spec.Suite(parent, title, definition)
    suite.load()
    @suite = parent

  # Adds a setup step to the current test case
  before: (action) ->
    @suite.beforeFilters.push action

  # Allows an assertion on a non-object value
  expect: (object) ->
    to: (matcher) ->
      result = matcher(object)
      throw new Spec.ExpectationError("expected #{result[1]}") unless result[0]
    notTo: (matcher) ->
      result = matcher(object)
      throw new Spec.ExpectationError("expected not #{result[1]}") if result[0]
  
  # Sets up an expectation
  expectation: (message) ->
    exp = new Spec.DelayedExpectation(message)
    @test.expectations.push exp
    exp
  
  # Syntactic sugar to create a before method that prepares a variable
  #
  # Example:
  #     given 'dog', -> new Dog()
  given: (name, definition) ->
    before ->
      @[name] = definition.call this
  
  # Creates a specificaition
  it: (args...) ->
    test = switch args.length
      when 1
        if typeof args[0] == 'function'
          # Test with automatically generated title
          test = new Spec.Test(@suite, args[0], Spec.Util.descriptionize(args[1]))
        else
          # Pending test
          test = new Spec.Test(@suite, args[0], -> pending() )
      when 2
        # Test with manual title
        test = new Spec.Test(@suite, args...)
    test && test.run this
    
  pending: ->
    @test.pending = true
  
  # Creates a specification that tests an attribute of subject
  #
  # Example:
  #     subject -> new Employee('Fred')
  #     its 'name', -> should equal('Fred')
  its: (attribute, definition) ->
    it "#{attribute} #{Spec.Util.descriptionize definition}", ->
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
    expect(@test.env.subject).to matcher

  # Runs a negative test against @subject
  # 
  # Example
  #     subject -> new Employee()
  #     it -> shouldNot be(null)
  shouldNot: (matcher) ->
    expect(@test.env.subject).notTo matcher

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