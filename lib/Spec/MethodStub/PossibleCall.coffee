# Represents a possible call path for a MethodStub - that is a combination
# of expected arguments and return values.
class window.Spec.MethodStub.PossibleCall
  constructor: (@original) ->

  # Defines the expected arguments for this PossibleCall. By default a
  # PossibleCall will accept any or no arguments. When you specify arguments
  # here, the PossibleCall will respond only to those arguments, and a test
  # failure will be recorded if it is called with incorrect arguments.
  with: (args...) ->
    @arguments = args
    this

  # Provides a return value for this PossibleCall
  andReturn: (value) ->
    @return = Spec.Util.reference(value)
    this

  # Causes this PossibleCall to pass through to the original method on the
  # object before it was stubbed out.
  andPassthrough: ->
    @return = @original

  # Sets an expectation that this PossibleCall be called as part of the test.
  #
  # This is used by window#shouldReceive, and doesn't need to be called
  # directly.
  expect: ->
    # TODO: Make this description better, possibly with name of
    # the method that should have been called
    @expectation ||= Spec.DelayedExpectation.add('get called')
    this

  # Delegates to expectation
  never: ->
    @expectation.never()
    this

  # Delegates to expectation
  twice: ->
    @expectation.twice()
    this

  # Delegates to expectation
  exactly: (times) ->
    @expectation.exactly times
    {times: this}

  # Checks if this PossibleCall matches the given array of arguments.
  #
  # A match is defined as having the same number of arguments, and each
  # argument having an equal string representation to its counterpart.
  matchesArguments: (args) ->
    if !@arguments
      true
    else if @arguments.length isnt args.length
      false
    else
      @_arraysMatch @arguments, args

  # Causes this PossibleCall to fulfil a call on the stubbed method. Fails
  # the test if the called arguments don't match expected arguments.
  call: (object, method, args) ->
    if @matchesArguments(args)
      @expectation.meet() if @expectation
      @return.apply object, args if @return
    else
      @_failOnInvalidArguments method, args
      null

  _arraysMatch: (a, b) ->
    for i in [0..a.length]
      return false if String(a[i]) isnt String(b[i])
    true

  _failOnInvalidArguments: (method, args) ->
    throw new Spec.ExpectationError(
      "expected ##{method} to be called#{@_argumentsString()}, " +
      "actual arguments: “#{args.join ', '}”"
    )

  _argumentsString: ->
    if @arguments
      " with arguments “#{@arguments.join ', '}”"
    else
      ''
