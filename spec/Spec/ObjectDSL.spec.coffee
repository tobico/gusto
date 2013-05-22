Spec.extend Spec.ObjectDSL

Spec.describe 'Spec.ObjectDSL', ->
  describe '#stub', ->
    context 'when method is already stubbed', ->
      it 'returns a PossibleCall for existing MethodStub'

    context 'when method has not been stubbed', ->
      it 'creates a new method stub and returns a Possiblecall'

  describe '#should', ->
    it 'calls expect().to'

  describe '#shouldNot', ->
    it 'calls expect().notTo'

  describe '#shouldReceive', ->
    it 'calls expect().toReceive'

  describe '#shouldNotReceive', ->
    it 'calls expect().notToReceive'
