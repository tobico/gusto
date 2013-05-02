Spec.extend Spec.MethodStub.PossibleCall

Spec.describe 'Spec.MethodStub.PossibleCall', ->
  given   'original', -> -> "I'm the original method"
  subject 'call',     ->
    new Spec.MethodStub.PossibleCall(@original)

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
      @call.matchesArguments().should equal true

    it 'is false if length of expected arguments is different', ->
      @call.with 'foo'
      @call.matchesArguments('foo', 'bar').should equal false

    it 'is false if one of the arguments is different', ->
      @call.with 'foo', 'bar'
      @call.matchesArguments('foo', 'zap').should equal false

    it 'is true if all arguments the same', ->
      @call.with 'foo', 'bar'
      @call.matchesArguments(['foo', 'bar']).should equal true

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

      it 'throws an error', ->
        (=>
          @call.call @object, 'awesomize', ['bar']
        ).should throwError 'expected #awesomize to be called with arguments “foo”, actual arguments: “bar”'
