Spec.describe 'Spec.Mock', ->
  subject 'mock', ->
    mock 'myMock', foo: -> 'bar'

  describe 'constructor', ->
    it 'sets name', ->
      @mock.name.should equal 'myMock'

    it 'stubs methods', ->
      @mock.foo.should beA Function
      @mock.foo._stub.should beA Spec.MethodStub
      @mock.foo().should equal 'bar'

  describe 'toString', ->
    it 'makes a string which includes name', ->
      String(@mock).should equal '[myMock Mock]'
