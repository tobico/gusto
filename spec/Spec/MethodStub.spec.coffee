Spec.extend Spec.MethodStub, Spec.MethodStub.PossibleCall

Spec.describe 'Spec.MethodStub', ->
  given 'test', -> mock 'test'
  given 'method', -> ->
  given 'object', -> {foo: @method}
  subject 'methodStub', -> new Spec.MethodStub(@test, @object, 'foo')

  describe 'constructor', ->
    it 'stashes the original method', ->
      @methodStub.original.should be @method

    it 'prepares possible calls list', ->
      expect(@methodStub.possibleCalls).to equal []

    it 'gives the object a stub method', ->
      @object.foo.shouldNot be @method
      @object.foo.should beA Function

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

    it 'assigns test for possible call', ->
      @methodStub.possibleCall().test.should be @test

    it 'assigns original method for possible call', ->
      @methodStub.possibleCall().original.should be @methodStub.original

    it 'keeps track of new PossibleCall in @possibleCalls', ->
      call = @methodStub.possibleCall()
      @methodStub.possibleCalls.length.should equal 1
      @methodStub.possibleCalls[0].should be call

    it 'puts the new possibleCall first in line', ->
      first = @methodStub.possibleCall()
      second = @methodStub.possibleCall()
      @methodStub.possibleCalls[0].should be second

Spec.describe 'Spec.MethodStub.PossibleCall', ->
  given 'test', -> mock 'test'
  given 'original', -> -> "I'm the original method"
  subject 'call', ->
    new Spec.MethodStub.PossibleCall(@test, @original)

  describe '#with', ->
    it 'sets @arguments to an array of arguments', ->
      @call.with 'foo', 'bar'
      @call.arguments.should == ['foo', 'bar']

  describe '#andReturn', ->
    it 'sets return function to a function that returns given value', ->
      @call.andReturn 'foo'
      @call.return.should beA Function
      @call.return().should equal 'foo'

  describe '#andPassthrough', ->
    it 'sets return function to the original method before stubbing', ->
      @call.andPassthrough()
      @call.return.should be @original

  describe '#expect', ->
    it 'creates an expectation'

  describe '#twice', ->
    given 'expectation', -> mock(twice: null)

    before ->
      @call.expectation = @expectation
    
    it 'delegates to expectation', ->
      @expectation.shouldReceive('twice')
      @call.twice()

    it 'returns the possibleCall', ->
      @call.twice().should be @call

  describe '#exactly', ->
    given 'expectation', -> mock(exactly: {times: null})

    before ->
      @call.expectation = @expectation
    
    it 'delegates to expectation', ->
      @expectation.shouldReceive('exactly')
      @call.exactly()

    it 'returns the possibleCall as .times', ->
      @call.exactly(3).times.should be @call

  describe '#matchesArguments', ->
    it 'is true if no required arguments', ->
      @call.matchesArguments().should beTrue

    it 'is false if length of expected arguments is different', ->
      @call.with 'foo'
      @call.matchesArguments('foo', 'bar').should beFalse

    it 'is false if one of the arguments is different', ->
      @call.with 'foo', 'bar'
      @call.matchesArguments('foo', 'zap').should beFalse

    it 'is true if all arguments the same', ->
      @call.with 'foo', 'bar'
      @call.matchesArguments(['foo', 'bar']).should beTrue

  describe '#call', ->
    given 'object', -> mock 'object'

    context 'when arguments match', ->
      before ->
        @call.with 'lets', 'be', 'awesome'

      it 'meets expectation', ->
        @call.expectation = expectation 'be met'
        @call.call @object, 'awesomize', ['lets', 'be', 'awesome']

      it 'calls the return function with object and arguments, and returns results', ->
        @call.stub('return').with('lets', 'be', 'awesome').andReturn('ok')
        @call.call(@object, 'awesomize', ['lets', 'be', 'awesome']).should equal 'ok'

    context 'when arguments do not match', ->
      before ->
        @call.with 'foo'

      it 'fails with an message about invalid arguments', ->
        @test.shouldReceive('fail').with('expected #awesomize to be called with arguments &ldquo;foo&rdquo;, actual arguments: &ldquo;bar&rdquo;')
        @call.call @object, 'awesomize', ['bar']
