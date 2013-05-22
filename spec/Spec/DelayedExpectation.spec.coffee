Spec.extend Spec.DelayedExpectation

Spec.describe 'Spec.DelayedExpectation', ->
  given   'message',     -> 'foo'
  subject 'expectation', -> new Spec.DelayedExpectation(@message)

  context 'class methods', ->
    subject 'klass', ->
      # Make a new copy of DelayedExpectation at the class level, so that
      # expectations that get added to it aren't as part of running these
      # tests
      Spec.Util.extend {expectations: []}, Spec.DelayedExpectation

    describe '.add', ->
      given 'add', -> @klass.add @message

      it 'returns a new DelayedExpectation', ->
        @add.should beA Spec.DelayedExpectation

      it 'adds the new expectation to collection', ->
        @klass.expectations.length.should == 1
        @klass.expectations[0].should be @add

    describe '.assert', ->
      context 'with an expectation', ->
        given 'expectation', -> @klass.add @message

        before -> @expectation.stub('assert')

        it 'asserts expectation', ->
          @expectation.shouldReceive('assert')
          Spec.DelayedExpectation.assert.call @klass

        it 'empties out the collection', ->
          Spec.DelayedExpectation.assert.call @klass
          @klass.expectations.should equal []

    describe '.reset', ->
      context 'with an expectation', ->
        given 'expectation', -> @klass.add @message

        it 'empties out the collection', ->
          Spec.DelayedExpectation.reset.call @klass
          @klass.expectations.should equal []

  describe 'a new DelayedExpectation', ->
    its 'met',     -> should equal 0
    its 'desired', -> should equal 1
    its 'message', -> should equal @message

  describe '#twice', ->
    it 'sets desired number of times to meet expectation to two', ->
      @expectation.twice()
      @expectation.desired.should equal 2

  describe '#exactly', ->
    it 'sets desired number of times to meet expectation to specified number', ->
      @expectation.exactly(5)
      @expectation.desired.should equal 5

    it 'lets you get the expectation again using .times', ->
      @expectation.exactly(3).times.should be @expectation

  describe '#meet', ->
    it 'increments number of times expectation was met', ->
      @expectation.meet()
      @expectation.met.should == 1

  describe '#assert', ->
    given 'test', -> mock 'test'

    context 'when expectation has not been met the desired number of times', ->
      it 'raises an error', ->
        message = ''
        try
          @expectation.assert()
        catch error
          message = error.message
        finally
          message.should equal "expected to #{@message} once, actually happened not at all"

    context 'when expectation has been met the desired number of times', ->
      before -> @expectation.meet()

      it "does nothing", ->
        @expectation.assert()
