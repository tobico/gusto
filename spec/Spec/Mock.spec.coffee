Spec.describe 'Spec.Mock', ->
  subject 'mock', ->
    mock 'myMock'

  describe 'constructor'

  describe 'toString', ->
    it 'makes a string which includes name', ->
      String(@mock).should equal '[myMock Mock]'
