Spec.describe 'Spec.DSL', ->
  describe 'describe', ->
    it 'adds a new suite to the current suite'
    it 'sets suite title'
    it 'sets suite definition'

  describe 'before', ->
    it 'adds a filter to the current suite'

  describe 'expect.to', ->
    it 'runs matcher on object'
    it 'throws an error if matcher does not match'
    it 'includes description from matcher'

  describe 'expect.notTo', ->
    it 'runs matcher on object'
    it 'throws an error if matcher matches'
    it 'includes description from matcher'

  describe 'given', ->
    it 'adds a filter to the current suite'
    it 'uses a name for the filter'

    describe 'generated filter', ->
      it 'calls the definition'
      it 'sets named test environment variable to result of definition'

  describe 'it', ->
    context 'with a title and a function', ->
      it 'creates a new test'
      it 'sets the title'
      it 'sets the function'

    context 'with only a title', ->
      it 'creates a pending test'
      it 'sets the title'

    context 'with only a function', ->
      it 'adds the function as a test'
      it 'generates a title from function source code'

  describe 'pending', ->
    it 'throws a pending error'

  describe 'its', ->
    it 'adds a new test'
    it 'uses attribute as subject'
    it 'generates a title from attribute name and definition source code'
    it "calls attribute if it's a function"

  describe 'should', ->
    it 'calls expect.to on subject'

  describe 'shouldNot', ->
    it 'calls expect.notTo on subject'

  describe 'mock', ->
    it 'makes a new mock'
    it 'uses name'
    it 'applies stub'
    it 'uses the name "mock" when no name given'
    it 'applies stubs when no name given'

  describe 'subject', ->
    it 'adds a filter to the current suite'
    it 'uses the name "subject" for the filter'

    describe 'generated filter', ->
      it 'calls the definition to get subject'
      it 'sets the current subject'
      it 'sets subject environment variable'
      it 'sets named environment variable if name given'

  describe 'context', ->
    it 'is the same as "describe"'

  describe 'specify', ->
    it 'is the same as "it"'
