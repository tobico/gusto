Spec.extend Spec.MethodStub, Spec.MethodStub.PossibleCall

Spec.describe 'Spec.MethodStub', ->
  given 'method', -> ->
  given 'object', -> {foo: @method}
  subject 'methodStub', -> new Spec.MethodStub(@object, 'foo')

  describe 'constructor', ->
    it 'stashes the original method', ->
      @methodStub.original.should be @method

    it 'prepares possible calls list', ->
      expect(@methodStub.possibleCalls).to equal []

    it 'gives the object a stub method', ->
      @object.foo.shouldNot be @method
      @object.foo.should beAFunction

    it 'attaches the method stub object to the new stubbed method', ->
      @object.foo._stub.should be @methodStub

  describe 'stub method', ->
    given 'matchingPossibleCall', -> mock(matchesArguments: true, call: null)
    given 'nonMatchingPossibleCall', -> mock(matchesArguments: false, call: null)

    context 'with multiple possible calls', ->
      before ->
        @methodStub.possibleCalls = [@matchingPossibleCall, @nonMatchingPossibleCall]

      it 'calls the possibleCall that matches arguments', ->
        @matchingPossibleCall.shouldReceive('call')
        @object.foo()

      it "doesn't call the possibleCall that doesn't match arguments", ->
        @nonMatchingPossibleCall.shouldNotReceive('call')
        @object.foo()

    context 'with only a single nonmatching possible call', ->
      before ->
        @methodStub.possibleCalls.push @nonMatchingPossibleCall

      it "gets called anyway", ->
        @nonMatchingPossibleCall.shouldReceive('call')
        @object.foo()

    context 'with multiple nonmatching possible calls', ->
      given 'anotherNonMatchingPossibleCall', -> mock(matchesArguments: false, call: null)

      before ->
        @methodStub.possibleCalls = [@nonMatchingPossibleCall, @anotherNonMatchingPossibleCall]

      it 'calls the last one', ->
        @nonMatchingPossibleCall.shouldNotReceive('call')
        @anotherNonMatchingPossibleCall.shouldReceive('call')
        @object.foo()

  describe '#possibleCall', ->
    it 'returns a new possible call', ->
      @methodStub.possibleCall().should beA Spec.MethodStub.PossibleCall

    it 'keeps track of new PossibleCall in @possibleCalls', ->
      call = @methodStub.possibleCall()
      @methodStub.possibleCalls.length.should equal 1
      @methodStub.possibleCalls[0].should be call

    it 'puts the new possibleCall first in line', ->
      first = @methodStub.possibleCall()
      second = @methodStub.possibleCall()
      @methodStub.possibleCalls[0].should be second

Spec.describe 'Spec.MethodStub.PossibleCall', ->
  given 'methodStub', -> mock 'methodStub'
  given 'originalMethod', -> -> "I'm original"
  subject 'call', ->
    new Spec.MethodStub.PossibleCall(@methodStub)

  before ->
    @methodStub.original = @originalMethod

  describe 'constructor', ->
    it 'assigns methodStub', ->
      @call.methodStub.should be @methodStub

  describe '#with', ->
    it 'sets @arguments to an array of arguments', ->
      @call.with 'foo', 'bar'
      @call.arguments.should == ['foo', 'bar']

  describe 'andReturn', ->
    it 'sets return function to a function that returns given value', ->
      @call.andReturn 'foo'
      @call.return.should beAFunction
      @call.return().should equal 'foo'

  describe 'andPassthrough', ->
    it 'sets return function to the original method before stubbing', ->
      @call.andPassthrough()
      @call.return.should be @originalMethod

  describe 'expect', ->
    it 'creates an expectation'

  describe 'twice', ->
    given 'expectation', -> mock(twice: null)

    before ->
      @call.expectation = @expectation
    
    it 'delegates to expectation', ->
      @expectation.shouldReceive('twice')
      @call.twice()

    it 'returns the possibleCall', ->
      @call.twice().should be @call