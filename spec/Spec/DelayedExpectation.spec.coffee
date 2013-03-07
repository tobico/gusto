Spec.extend Spec.DelayedExpectation

Spec.describe 'Spec.DelayedExpectation', ->
  given   'message',     -> 'foo'
  subject 'expectation', -> new Spec.DelayedExpectation(@message)

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

  describe '#check', ->
    given 'test', -> mock 'test'

    context 'when expectation has not been met the desired number of times', ->
      it 'fails the test with a nice error message', ->
        @test.shouldReceive('fail').with("expected to #{@message} once, actually happened not at all")
        @expectation.check @test

    context 'when expectation has been met the desired number of times', ->
      before -> @expectation.meet()

      it "doesn't fail the test", ->
        @test.shouldNotReceive 'fail'
        @expectation.check @test
