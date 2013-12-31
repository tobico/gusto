Spec.extend Spec.Test

Spec.describe 'Spec.Test', ->
  given 'title', -> 'is a test test to test tests'
  given 'definition', -> mock 'definition', call: null
  subject 'test', -> new Spec.Test(@title, @definition)

  describe 'a new test', ->
    it 'has a title', ->
      @test.title.should equal @title

    it 'has a definition', ->
      @test.definition.should be @definition

  describe '#run', ->
    given 'filtersRun', -> false
    given 'filters', ->
      [=> @filtersRun = true]

    it 'runs the filters', ->
      @test.run @filters
      @filtersRun.should equal true

    it 'calls the definition', ->
      @definition.shouldReceive('call').with(@test.env)
      @test.run @filters

    context 'when the test passes', ->
      before ->
        @test.definition = -> 'apples'.should equal 'apples'

      it 'reports title and status', ->
        pending 'work out how to test this'
        @test.run(@filters).should include
          title:  @title
          status: 'passed'

    context 'when the test fails', ->
      before ->
        @test.definition = -> 'orange'.should equal 'apples'

      it 'reports title and status', ->
        pending 'work out how to test this'
        @test.run(@filters).should include
          title:  @title
          status: 'failed'
