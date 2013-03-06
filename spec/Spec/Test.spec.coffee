Spec.describe 'Spec.Test', ->
  given 'ul', -> mock 'ul', append: null
  given 'suite', -> mock 'suite', runBeforeFilters: null
  before -> @suite.ul = @ul

  subject 'test', -> new Spec.Test(@suite, 'test', ->)

  describe 'a new test', ->
    it 'sets pending to false', ->
      @test.pending.should equal false

    it 'sets failed to false', ->
      @test.failed.should equal false

    it 'creates an empty object for env', ->
      @test.env.should == {}

    it 'creates an empty array for expectations', ->
      @test.env.should == []

  describe 'run', ->
    given 'root', -> mock 'root'

    it 'sets root.test to self before calling definition', ->
      testInDefinition = null

      @test.definition = =>
        testInDefinition = @root.test

      @test.run @root
      testInDefinition.should be @test

    it 'sets root.test to null after calling definition', ->
      @test.run @root
      expect(@root.test).to be null
