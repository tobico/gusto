window.Spec ||= {}

window.Spec.ObjectDSL =
  # Stubs a method on object
  stub: (method) ->
    stub = if @[method] && @[method]._stub
      @[method]._stub
    else
      new Spec.MethodStub(this, method)
    stub.possibleCall()

  # Tests for a positive match
  should: (matcher) ->
    expect(this).to matcher

  # Tests for a negative match
  shouldNot: (matcher) ->
    expect(this).notTo matcher

  # Creates a stub method with an expectation
  shouldReceive: (method) ->
    @stub(method).expect()

  # Creates a stub method, with an expectation of no calls
  shouldNotReceive: (name) ->
    @shouldReceive(name).exactly(0).times
