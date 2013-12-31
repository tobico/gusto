window.Spec ||= {}

window.Spec.ObjectDSL =
  # Stubs a method on object
  stub: (method) ->
    Spec.MethodStub.stub(this, method)

  # Tests for a positive match
  should: (matcher) ->
    expect(this).to matcher

  # Tests for a negative match
  shouldNot: (matcher) ->
    expect(this).notTo matcher

  # Creates a stub method with an expectation
  shouldReceive: (method) ->
    expect(this).toReceive method

  # Creates a stub method, with an expectation of no calls
  shouldNotReceive: (method) ->
    expect(this).notToReceive method
