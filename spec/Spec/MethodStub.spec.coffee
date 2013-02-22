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

  describe 'stub method', ->
    it 'meets an expectation when called'

    it 'calls the return function with arguments, and returns result'

  describe '#with', ->
    it 'returns a new possible call', ->
      @methodStub.with('foo').should beA Spec.MethodStub.PossibleCall

    it 'sets arguments for new possible call', ->
      @methodStub.with('foo').arguments.should equal ['foo']

    it 'keeps track of new PossibleCall in @possibleCalls', ->
      call = @methodStub.with('foo')
      @methodStub.possibleCalls.length.should equal 1
      @methodStub.possibleCalls[0].should be call