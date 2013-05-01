Spec.extend Spec.Test

Spec.describe 'Spec.Test', ->
  given 'ul',         -> mock 'ul', append: null
  given 'suite',      -> mock 'suite', runBeforeFilters: null
  given 'definition', -> mock 'definition', call: null
  before -> @suite.ul = @ul

  subject 'test', -> new Spec.Test(@suite, 'test', @definition)

  describe 'a new test', ->
    it 'has status of passed', ->
      @test.status.should equal 'passed'

    it 'creates an empty object for env', ->
      @test.env.should == {}

    it 'creates an empty array for expectations', ->
      @test.env.should == []

  describe '#run', ->
    given 'root', -> mock 'root'

    it 'sets root.test to self before calling definition', ->
      testInDefinition = null

      @test.definition = =>
        testInDefinition = @root.test

      @test.run @root
      testInDefinition.should be @test

    it 'runs ruite before filters on env', ->
      @suite.shouldReceive('runBeforeFilters').with(@test.env)
      @test.run @root

    it 'calls the definition', ->
      @definition.shouldReceive('call').with(@test.env)
      @test.run @root

    it 'checks each expectation', ->
      exp = mock 'expectation'
      exp.shouldReceive('check')
      @test.expectations.push exp
      @test.run @root

    it 'sets root.test to null after calling definition', ->
      @test.run @root
      expect(@root.test).to be null

    context 'when the test passes', ->
      it 'reports success'

    context 'when the test is marked as pending', ->
      it 'reports pending'

    context 'when the test fails', ->
      it 'reports failure'
      it 'reports full test title'
      it 'reports error message'
      it 'reports stack trace'

  describe '#pending', ->
    it 'sets the test status to pending', ->
      @test.pending()
      @test.status.should equal 'pending'

  describe '#report', ->
    it 'returns a report hash', ->
      @test.report().should equal {
        title:  'test'
        status: 'passed'
        error:  null
      }
